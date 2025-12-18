import { promptAction, router } from '@kit.ArkUI';
import { shopBagItem } from '../model/model';
import { getStorage } from '../utils/storage';
import { deleteShopCart, findAddress, pay } from '../api/api';

// 定义地址接口
interface AddressItem {
  id: number | string;
  name: string;
  phone: string;
  address: string;
  isDefault: boolean;
}

@Entry
@Component
struct OrderSettle {
  // 接收上个页面传来的参数
  @State orderList: shopBagItem[] = [];
  @State totalPrice: string = "0.00";
  // 地址相关状态
  @State addressList: AddressItem[] = [];
  @State currentAddress: AddressItem | null = null;
  @State isShowAddressSheet: boolean = false;
  @State isLoadingAddress: boolean = false;
  // 内存中的 Token
  @StorageProp('token') token: string = '';

  async aboutToAppear() {
    // 1. 获取路由参数
    let params = router.getParams() as Record<string, Object>;
    if (params) {
      this.orderList = params['list'] as shopBagItem[] || [];
      this.totalPrice = params['total'] as string || "0.00";
    }

    // 2. 获取 Token
    let finalToken = this.token;
    if (!finalToken) {
      try {
        let context = getContext(this);
        let diskToken = await getStorage("user_token", context);
        if (diskToken) {
          finalToken = diskToken.toString();
          AppStorage.setOrCreate('token', finalToken);
        }
      } catch (e) {
        console.error('[OrderSettle] 读取硬盘 Token 失败:', JSON.stringify(e));
      }
    }

    // 3. 初始获取地址
    if (finalToken) {
      this.getAddressList(finalToken);
    }
  }

  onPageShow() {
    if (this.token) {
      console.info('[OrderSettle] 页面显示，刷新地址列表...');
      this.getAddressList(this.token);
    }
  }

  // 获取地址列表
  async getAddressList(useToken?: string) {
    let targetToken = useToken || this.token;
    if (!targetToken) {
      return;
    }

    if (this.addressList.length === 0) {
      this.isLoadingAddress = true;
    }

    try {
      let res = await findAddress(targetToken);

      let resData: Record<string, Object> =
        (typeof res.result === 'string' ? JSON.parse(res.result) : res.result) as Record<string, Object>;

      let originList: Array<Record<string, Object>> = [];
      if (Array.isArray(resData.result)) {
        originList = resData.result as Array<Record<string, Object>>;
      } else if (Array.isArray(resData.data)) {
        originList = resData.data as Array<Record<string, Object>>;
      }

      this.addressList = originList.map((item: Record<string, Object>) => {
        return {
          id: item.aid as string,
          name: item.name as string,
          phone: item.tel as string,
          address: `${item.province || ''}${item.city || ''}${item.county || ''} ${item.addressDetail || ''}`,
          isDefault: item.isDefault === 1 || item.isDefault === true
        } as AddressItem;
      });

      let stillExists = false;
      if (this.currentAddress) {
        stillExists = this.addressList.some(item => item.id === this.currentAddress?.id);
      }

      if ((!this.currentAddress || !stillExists) && this.addressList.length > 0) {
        let defaultAddr = this.addressList.find(item => item.isDefault);
        this.currentAddress = defaultAddr ? defaultAddr : this.addressList[0];
      }

    } catch (err) {
      console.error('获取地址失败:', JSON.stringify(err));
    } finally {
      this.isLoadingAddress = false;
    }
  }

  @Builder
  AddressSheetBuilder() {
    Column() {
      Row() {
        Text("").width(24)
        Text("选择收货地址").fontSize(18).fontWeight(FontWeight.Bold)
        Text("×")
          .fontSize(28)
          .fontColor(Color.Gray)
          .onClick(() => {
            this.isShowAddressSheet = false;
          })
      }
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 15, bottom: 15 })
      .border({ width: { bottom: 1 }, color: "#f5f5f5" })

      if (this.isLoadingAddress && this.addressList.length === 0) {
        Column() {
          Text("加载地址中...").fontColor(Color.Gray).margin({ top: 50 })
        }.layoutWeight(1).width('100%')
      } else if (this.addressList.length === 0) {
        Column() {
          Text("暂无收货地址").fontColor(Color.Gray).fontSize(16).margin({ top: 50 })
          Text("请点击下方按钮添加").fontColor(Color.Gray).fontSize(14).margin({ top: 5 })
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      } else {
        List() {
          ForEach(this.addressList, (item: AddressItem) => {
            ListItem() {
              Row() {
                if (this.currentAddress?.id === item.id) {
                  Text("√")
                    .fontColor($r("app.color.theme_color"))
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .margin({ right: 10 })
                } else {
                  Text()
                    .width(18).height(18)
                    .border({ width: 1, color: Color.Gray, radius: 9 })
                    .margin({ right: 12 })
                }

                Column({ space: 5 }) {
                  Row({ space: 10 }) {
                    Text(item.name).fontWeight(FontWeight.Bold).fontSize(16)
                    Text(item.phone).fontSize(14).fontColor(Color.Gray)
                    if (item.isDefault) {
                      Text("默认")
                        .fontSize(10)
                        .fontColor(Color.White)
                        .backgroundColor($r("app.color.theme_color"))
                        .padding({ left: 4, right: 4 })
                        .borderRadius(4)
                    }
                  }

                  Text(item.address)
                    .fontSize(13).fontColor('#666')
                    .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width("100%")
              .padding({ top: 15, bottom: 15 })
              .border({ width: { bottom: 0.5 }, color: "#f0f0f0" })
              .onClick(() => {
                this.currentAddress = item;
                this.isShowAddressSheet = false;
              })
            }
          })
        }
        .layoutWeight(1)
        .width("100%")
      }

      Button("新增地址")
        .width("90%")
        .height(45)
        .backgroundColor($r("app.color.theme_color"))
        .margin({ bottom: 10, top: 10 })
        .onClick(() => {
          this.isShowAddressSheet = false;
          router.pushUrl({ url: "pages/AddressAdd" });
        })
    }
    .width("100%")
    .height("100%")
    .padding({ left: 15, right: 15 })
    .backgroundColor(Color.White)
  }

  build() {
    Column() {
      // 1. 顶部导航
      Row() {
        Text("< 返回")
          .fontColor($r("app.color.theme_color"))
          .onClick(() => router.back())
        Text("订单结算").fontSize(18).fontWeight(FontWeight.Bold)
        Text("   ")
      }
      .width("100%")
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 15, right: 15 })
      .backgroundColor(Color.White)

      // 2. 中间滚动区域
      Scroll() {
        Column({ space: 15 }) {

          // --- 地址选择卡片 ---
          Column() {
            Row() {
              Text("收货地址").fontSize(16).fontWeight(FontWeight.Medium)
              Text(">")
                .fontSize(18).fontColor("#999").fontWeight(FontWeight.Bold)
            }
            .width("100%")
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ bottom: 10 })

            if (this.currentAddress) {
              Row({ space: 10 }) {
                Text(this.currentAddress.name).fontSize(18).fontWeight(FontWeight.Bold)
                Text(this.currentAddress.phone).fontSize(16)
                if (this.currentAddress.isDefault) {
                  Text("默认")
                    .fontSize(10)
                    .fontColor(Color.White)
                    .backgroundColor($r("app.color.theme_color"))
                    .padding(3)
                    .borderRadius(4)
                }
              }
              .width('100%').margin({ bottom: 5 })

              Text(this.currentAddress.address)
                .fontSize(14).fontColor('#666')
                .width('100%')
            } else {
              Row() {
                Text("请选择收货地址")
                  .fontSize(14).fontColor($r("app.color.theme_color"))
              }
              .width("100%")
              .padding({ top: 10, bottom: 10 })
            }
          }
          .width("100%")
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(15)
          .onClick(() => {
            this.isShowAddressSheet = true;
          })

          // --- 订单信息卡片 ---
          Column() {
            Text("订单详情").fontSize(15).fontWeight(FontWeight.Medium)
              .width("100%").margin({ bottom: 15 })

            List() {
              ForEach(this.orderList, (item: shopBagItem) => {
                ListItem() {
                  Row({ space: 10 }) {
                    Image(item.small_img).width(70).height(70).borderRadius(5)

                    Column() {
                      Text(item.name).fontSize(15).fontWeight(FontWeight.Bold)
                      Text(item.enname).fontSize(12).fontColor(Color.Gray).maxLines(1)
                      Text(item.rule).fontSize(12).fontColor(Color.Gray).margin({ top: 5 })

                      Row() {
                        Text("￥" + item.price).fontColor(Color.Red).fontSize(16)
                        Text("x" + item.count).fontSize(14)
                      }
                      .width("100%")
                      .justifyContent(FlexAlign.SpaceBetween)
                      .margin({ top: 5 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width("100%")
                  .padding({ bottom: 15 })
                }
              })
            }

            Divider().color('#f0f0f0')

            Row() {
              Text(`共计 ${this.orderList.length} 件商品`).fontSize(13).fontColor(Color.Gray)
              Row() {
                Text("合计: ").fontSize(14)
                Text("￥" + this.totalPrice)
                  .fontSize(18).fontColor(Color.Red).fontWeight(FontWeight.Bold)
              }
            }
            .width("100%")
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 15 })
          }
          .width("100%")
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(15)
        }
        .width("100%")
        .padding(15)
        .constraintSize({ minHeight: '100%' })
      }
      .layoutWeight(1)
      .align(Alignment.Top)

      // 3. 底部结算按钮
      Column() {
        Button('立即结算', { type: ButtonType.Capsule })
          .backgroundColor('#0C34BA')
          .width('90%')
          .height(45)
          .margin({ top: 10, bottom: 10 })
          .onClick(async () => {
            // 1. 校验地址
            if (!this.currentAddress) {
              promptAction.showToast({ message: '请先选择收货地址' });
              return;
            }

            // 2. 提取购物车ID (sid)
            let sids: string[] = [];
            this.orderList.forEach(item => {
              if (item.sid) {
                sids.push(item.sid);
              }
            });

            if (sids.length === 0) {
              promptAction.showToast({ message: '订单数据异常' });
              return;
            }

            try {
              // 3. 调用结算接口
              let payRes = await pay(
                this.token,
                sids,
                this.currentAddress.phone,
                this.currentAddress.address,
                this.currentAddress.name
              );

              console.info('下单成功:', payRes.result);
              await deleteShopCart(this.token, sids);
              promptAction.showToast({ message: '支付成功，正在返回...' });

              router.back();

            } catch (err) {
              console.error('结算流程失败:', JSON.stringify(err));
              promptAction.showToast({ message: '订单提交失败，请重试' });
            }
          })
      }
      .width("100%")
      .backgroundColor(Color.White)
      .padding({ bottom: 20 })
    }
    .width("100%")
    .height("100%")
    .backgroundColor('#F5F5F5')
    .bindSheet($$this.isShowAddressSheet, this.AddressSheetBuilder(), {
      height: "60%",
      dragBar: true,
      backgroundColor: Color.White
    })
  }
}
