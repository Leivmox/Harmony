// 数据接口
import { findAllShopcart, modifyShopcartCount, removeShopcart } from '../api/api';
// 购物车数据类型约束
import { shopBagItem } from '../model/model';
import { getStorage } from '../utils/storage';
import { router, promptAction } from '@kit.ArkUI';
import { debounce } from '../utils/debounce';

/**
 * @description 修改购物车商品数量(防抖)
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

  // 添加一个标记，防止短时间内重复刷新
  private isRefreshing: boolean = false;

  /**
   * 删除功能封装
   */
  deleteItem(index: number) {
    if (!this.shopbag_list[index]) return;

    let sids: string[] = [];
    sids.push(this.shopbag_list[index].sid);

    removeShopcart(this.user_token, JSON.stringify(sids))
      .then(res => {
        let resBody = res.result as Record<string, Object>;
        console.log("删除结果 =>", JSON.stringify(resBody));

        if ((resBody['code'] as number) == 7000) {
          this.shopbag_list.splice(index, 1);
          this.count_arr.splice(index, 1);
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

  // 获取购物车商品
  private findAllShopcart() {
    if (this.user_token.length) {
      // 标记正在刷新
      this.isRefreshing = true;

      findAllShopcart(this.user_token)
        .then(res => {
          let responseBody = res.result as Record<string, Object>;
          let listData = responseBody['result'] as shopBagItem[];

          // 强制覆盖数据
          this.shopbag_list = listData ? listData : [];
          console.log("购物车数据成功加载 =>", JSON.stringify(this.shopbag_list))

          // 初始化数量数组
          let count_arr: number[] = this.shopbag_list.map((v: shopBagItem) => {
            return Number(v.count);
          })
          this.count_arr = count_arr;
        })
        .catch((err: Error) => {
          console.error("获取购物车失败:", JSON.stringify(err));
        })
        .finally(() => {
          this.isRefreshing = false;
        })
    }
  }

  /**
   * 统一的数据初始化方法
   */
  initData() {
    // 1. 获取 Token
    let token = getStorage("user_token", getContext(this));
    this.user_token = token ? token.toString() : "";

    console.log("ShopBag 尝试刷新数据, Token:", this.user_token);

    // 2. 如果有 token，请求数据
    if (this.user_token) {
      this.findAllShopcart();
    } else {
      this.shopbag_list = [];
      this.count_arr = [];
    }
  }

  // 1. 保留 onPageShow，以防你是通过 router 跳转进来的
  onPageShow() {
    console.log("ShopBag onPageShow 触发");
    this.initData();
  }

  // 2. 页面首次加载
  aboutToAppear() {
    console.log("ShopBag aboutToAppear 触发");
    this.initData();
  }

  build() {
    Column() {
      // 1. 顶部导航
      Row() {
        Text("< 返回").fontColor($r("app.color.theme_color"))
          .onClick(() => { router.back() })

        Text("购物袋")

        // 【新增】手动刷新按钮，防止自动刷新失效时可以用
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

      // 2. 背景
      Image($r("app.media.shopbag_bg")).width("100%")

      // 3. 列表区域
      Scroll() {
        // === 修改点 A：Column ===
        Column() {
          if (!this.user_token.length) {
            Row() {
              Text("还未登录，先")
              Text("登录")
                .fontColor($r("app.color.theme_color"))
                .onClick(() => {
                  router.pushUrl({ url: "pages/LoginPage" })
                })
            }
            // 未登录提示也会自动居中，不需要 margin-top 了
          }
          else if (!this.shopbag_list.length) {
            // === 修改点 B：空状态居中 ===
            Column() {
              Text("目前还没有商品 (点击右上角刷新试试)")
                .fontColor(Color.Gray)
                .fontSize(14)
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
          else {
            List() {
              ForEach(this.shopbag_list, (item: shopBagItem, index: number) => {
                ListItem() {
                  Row({ space: 10 }) {
                    Checkbox({ group: "shopbagCheckBox" })
                    Image(item.small_img).width(90).height(90)

                    Column() {
                      Row() {
                        Text(item.name).margin({ right: 20 }).fontSize(14)
                        Text(item.rule).fontSize(14)
                      }
                      Text(item.enname)
                        .width("100%").fontSize(14).maxLines(1)
                        .margin({ bottom: 20 })
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      Row() {
                        Text("￥" + item.price).fontSize(14)

                        Row({ space: 10 }) {
                          // 减号
                          Button("-")
                            .width(24).height(24).padding(0)
                            .backgroundColor(Color.White).fontColor(Color.Red)
                            .border({ width: 1, color: Color.Red, style: BorderStyle.Solid })
                            .type(ButtonType.Circle)
                            .onClick(() => {
                              let currentCount = this.count_arr[index];
                              if (currentCount > 1) {
                                this.count_arr[index] = currentCount - 1;
                                f(this.user_token, this.shopbag_list[index].sid, String(this.count_arr[index]))
                              } else {
                                AlertDialog.show({
                                  title: '提示',
                                  message: '确定要移除该商品吗？',
                                  autoCancel: true,
                                  alignment: DialogAlignment.Bottom,
                                  offset: { dx: 0, dy: -20 },
                                  primaryButton: { value: '取消', action: () => {} },
                                  secondaryButton: {
                                    value: '删除', fontColor: Color.Red,
                                    action: () => { this.deleteItem(index); }
                                  }
                                })
                              }
                            })

                          TextInput({ text: String(this.count_arr[index]) })
                            .width(50).type(InputType.Number).textAlign(TextAlign.Center)
                            .backgroundColor(Color.White).padding(0)
                            .onChange((v: string) => {
                              if (new RegExp(/^0/).test(v)) v = v.slice(0, -1);
                              this.count_arr[index] = Number(v) ? Number(v) : 1;
                              if(v) f(this.user_token, this.shopbag_list[index].sid, String(this.count_arr[index]));
                            })
                            .onBlur(() => {
                              if (!this.count_arr[index]) this.count_arr[index] = 1;
                            })

                          // 加号
                          Button("+")
                            .width(24).height(24).padding(0)
                            .backgroundColor(Color.Red).type(ButtonType.Circle)
                            .onClick(() => {
                              let i = this.count_arr[index];
                              this.count_arr[index] = ++i;
                              f(this.user_token, this.shopbag_list[index].sid, String(this.count_arr[index]))
                            })
                        }
                      }
                      .width("100%").justifyContent(FlexAlign.SpaceBetween)
                    }
                    .layoutWeight(1).alignItems(HorizontalAlign.Start)
                  }
                  .padding(10).backgroundColor(Color.White)
                }
                .swipeAction({
                  end: this.itemEnd(index, () => { this.deleteItem(index) }),
                  edgeEffect: SwipeEdgeEffect.Spring
                })
              })
            }
          }
        }
        .width("100%")
        // === 修改点 C：核心居中逻辑 ===
        // 1. 让内部 Column 最小高度占满 Scroll
        .constraintSize({ minHeight: '100%' })
        // 2. 如果没有商品(长度为0)，则垂直居中；否则顶部对齐
        .justifyContent(this.shopbag_list.length === 0 ? FlexAlign.Center : FlexAlign.Start)
      }
      .width("100%")
      // 占据剩余所有高度
      .layoutWeight(1)
      .align(Alignment.Top)


      // 4. 底部结算栏
      Row({ space: 10 }) {
        Row() {
          CheckboxGroup({ group: "shopbagCheckBox" })
          Text("全选")
        }
        Row() {
          Text("合计:")
          Text("￥0.00")
        }
        .layoutWeight(1).justifyContent(FlexAlign.End)

        Button("提交订单")
          .linearGradient({
            angle: 90,
            colors: [[0xfe5d33, 0.2], [0xee0d26, 1.0]]
          })
      }
      .padding({ left: 10, right: 10 })
      .backgroundColor(Color.White)
    }
    .height("100%")
    .backgroundColor(0xefefef)
    // =================================================================
    // 【关键修复】使用 onVisibleAreaChange 监听组件是否可见
    // =================================================================
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      // 当组件完全可见时，并且没有正在刷新，则执行刷新
      if (isVisible && currentRatio >= 1.0 && !this.isRefreshing) {
        console.log("ShopBag 可见，触发自动刷新");
        this.initData();
      }
    })
  }
}
