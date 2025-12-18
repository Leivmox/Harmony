import { findAllShopcart, modifyShopcartCount, removeShopcart } from '../api/api';
import { shopBagItem } from '../model/model';
import { getStorage } from '../utils/storage';
import { promptAction, router } from '@kit.ArkUI';
import { debounce } from '../utils/debounce';

/**
 * @description 修改购物车商品数量
 */
let f = debounce((token: string, sid: string, count: string) => {
  modifyShopcartCount(token, sid, count)
    .then(res => {
      let resData = Object(res).result as Record<string, Object>;
      console.log("修改购物车数量(接口版) =>", JSON.stringify(resData));
    })
}, 500);

@Entry
@Component
export default struct ShopBag {
  @State shopbag_list: shopBagItem[] = [];
  @State count_arr: number[] = [];
  @State user_token: string = "";
  @State select_arr: boolean[] = [];
  @State totalPrice: string = "0.00";
  @State isAllSelected: boolean = false;
  private isRefreshing: boolean = false;

  /**
   * 核心算法：计算总价
   * 只有当 select_arr[i] 为 true 时，才计算该商品价格
   */
  calcTotal() {
    let total = 0;
    this.shopbag_list.forEach((item, index) => {
      if (this.select_arr[index]) {
        let price = parseFloat(item.price as string) || 0;
        let count = this.count_arr[index] || 1;

        total += price * count;
      }
    });
    this.totalPrice = total.toFixed(2);

    if (this.select_arr.length > 0) {
      this.isAllSelected = this.select_arr.every(val => val === true);
    } else {
      this.isAllSelected = false;
    }
  }

  /**
   * 删除功能
   */
  deleteItem(index: number) {
    if (!this.shopbag_list[index]) {
      return;
    }

    let sids: string[] = [];
    sids.push(this.shopbag_list[index].sid);

    removeShopcart(this.user_token, JSON.stringify(sids))
      .then(res => {
        let resBody = res.result as Record<string, Object>;
        if ((resBody['code'] as number) == 7000) {
          this.shopbag_list.splice(index, 1);
          this.count_arr.splice(index, 1);
          this.select_arr.splice(index, 1);
          this.calcTotal();
          promptAction.showToast({ message: '删除成功' });
        }
      })
  }

  @Builder
  itemEnd(idx: number, onClick: () => void) {
    Text("删除")
      .padding(5)
      .fontSize(16)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .width(60)
      .height("100%")
      .backgroundColor(Color.Red)
      .borderRadius({ topRight: 10, bottomRight: 10 })
      .onClick(onClick)
  }

  private findAllShopcart() {
    if (this.user_token.length) {
      this.isRefreshing = true;
      findAllShopcart(this.user_token)
        .then(res => {
          let responseBody = res.result as Record<string, Object>;
          let listData = responseBody['result'] as shopBagItem[];

          this.shopbag_list = listData ? listData : [];

          let count_arr: number[] = this.shopbag_list.map((v: shopBagItem) => {
            return Number(v.count);
          })
          this.count_arr = count_arr;

          this.select_arr = new Array(this.shopbag_list.length).fill(false);

          this.totalPrice = "0.00";
          this.isAllSelected = false;
        })
        .finally(() => {
          this.isRefreshing = false;
        })
    }
  }

  initData() {
    let token = getStorage("user_token", getContext(this));
    this.user_token = token ? token.toString() : "";
    if (this.user_token) {
      this.findAllShopcart();
    } else {
      this.shopbag_list = [];
      this.count_arr = [];
      this.select_arr = [];
    }
  }

  onPageShow() {
    this.initData();
  }

  build() {
    Column() {
      Row() {
        Text("< 返回").fontColor($r("app.color.theme_color"))
          .onClick(() => {
            router.back()
          })
        Text("购物袋")
        Text("刷新").fontColor($r("app.color.theme_color"))
          .onClick(() => {
            this.initData();
            promptAction.showToast({ message: '已刷新' });
          })
      }
      .width("100%")
      .height(56)
      .padding({ left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)

      Image($r("app.media.shopbag_bg")).width("100%")

      Scroll() {
        Column() {
          if (!this.user_token.length) {
            Row() {
              Text("还未登录，先")
              Text("登录").fontColor($r("app.color.theme_color"))
                .onClick(() => {
                  router.pushUrl({ url: "pages/LoginPage" })
                })
            }
            .margin({ top: 20 })
          } else if (!this.shopbag_list.length) {
            Column() {
              Image($r("app.media.Null")).width(100).height(100).opacity(0.5).margin({ bottom: 10 })
              Text("购物车空空如也").fontColor(Color.Gray).fontSize(14)
            }
            .width('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          } else {
            List() {
              ForEach(this.shopbag_list, (item: shopBagItem, index: number) => {
                ListItem() {
                  Row({ space: 10 }) {
                    Checkbox({ name: 'item' + index })
                      .select(this.select_arr[index])
                      .onChange((value: boolean) => {
                        this.select_arr[index] = value;
                        this.calcTotal();
                      })

                    Image(item.small_img)
                      .width(90)
                      .height(90)
                      .borderRadius(4)
                      .objectFit(ImageFit.Cover)
                      .backgroundColor('#f5f5f5')

                    Column() {
                      Row() {
                        Text(item.name)
                          .fontSize(14)
                          .fontWeight(FontWeight.Bold)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .layoutWeight(1)
                      }

                      Text(item.rule)
                        .fontSize(12).fontColor('#999')
                        .margin({ top: 4, bottom: 4 })

                      Row() {
                        Text("￥" + item.price).fontSize(16).fontColor(Color.Red).fontWeight(FontWeight.Bold)

                        Row({ space: 0 }) {
                          Button("-")
                            .width(26)
                            .height(26)
                            .padding(0)
                            .backgroundColor('#f5f5f5')
                            .fontColor('#333')
                            .type(ButtonType.Normal)
                            .borderRadius({ topLeft: 13, bottomLeft: 13 })
                            .onClick(() => {
                              if (this.count_arr[index] > 1) {
                                this.count_arr[index]--;
                                f(this.user_token, item.sid, String(this.count_arr[index]));
                                this.calcTotal();
                              } else {
                                this.deleteItem(index);
                              }
                            })

                          Text(String(this.count_arr[index]))
                            .width(36)
                            .height(26)
                            .textAlign(TextAlign.Center)
                            .fontSize(13)
                            .backgroundColor('#f5f5f5')

                          Button("+")
                            .width(26)
                            .height(26)
                            .padding(0)
                            .backgroundColor('#f5f5f5')
                            .fontColor('#333')
                            .type(ButtonType.Normal)
                            .borderRadius({ topRight: 13, bottomRight: 13 })
                            .onClick(() => {
                              this.count_arr[index]++;
                              f(this.user_token, item.sid, String(this.count_arr[index]));
                              this.calcTotal();
                            })
                        }
                      }
                      .width("100%").justifyContent(FlexAlign.SpaceBetween)
                    }
                    .layoutWeight(1).alignItems(HorizontalAlign.Start).height(90).justifyContent(FlexAlign.SpaceBetween)
                  }
                  .padding(10).backgroundColor(Color.White).margin({ bottom: 10 }).borderRadius(8)
                }
                .swipeAction({
                  end: this.itemEnd(index, () => {
                    this.deleteItem(index)
                  }),
                  edgeEffect: SwipeEdgeEffect.Spring
                })
              })
            }
          }
        }
        .constraintSize({ minHeight: '100%' })
        .justifyContent(this.shopbag_list.length === 0 ? FlexAlign.Center : FlexAlign.Start)
        .padding({ left: 10, right: 10, top: 10 })
      }
      .layoutWeight(1)
      .align(Alignment.Top)
      .backgroundColor('#f5f5f5')

      Row() {
        Row() {
          Checkbox({ name: 'all' })
            .select(this.isAllSelected)
            .onChange((value: boolean) => {
              this.isAllSelected = value;
              for (let i = 0; i < this.select_arr.length; i++) {
                this.select_arr[i] = value;
              }
              this.calcTotal();
            })
          Text("全选").fontSize(14).fontColor('#333')
        }

        Row({ space: 10 }) {
          Row() {
            Text("合计: ").fontSize(14)
            Text("￥" + this.totalPrice).fontSize(18).fontColor(Color.Red).fontWeight(FontWeight.Bold)
          }

          Button(`提交订单`)
            .height(36)
            .linearGradient({
              angle: 90,
              colors: [[0xfe5d33, 0.2], [0xee0d26, 1.0]]
            })
            .onClick(() => {
              let selectedItems: shopBagItem[] = [];
              let finalTotal = 0;

              this.shopbag_list.forEach((item, i) => {
                if (this.select_arr[i]) {
                  let currentItem = item;
                  currentItem.count = this.count_arr[i];
                  selectedItems.push(currentItem);
                  finalTotal += Number(item.price) * this.count_arr[i];
                }
              });

              if (selectedItems.length === 0) {
                promptAction.showToast({ message: '请先选择要购买的商品' });
                return;
              }

              router.pushUrl({
                url: "pages/OrderSettle",
                params: {
                  list: selectedItems,
                  total: finalTotal.toFixed(2)
                }
              })
            })
        }
      }
      .width('100%')
      .padding({
        left: 15,
        right: 15,
        top: 10,
        bottom: 10
      })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height("100%")
    .backgroundColor('#f5f5f5')
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0 && !this.isRefreshing) {
        this.initData();
      }
    })
  }
}
