import { promptAction, router } from '@kit.ArkUI';
import { confirmReceive, findOrder, removeOrder } from '../api/api';
import { getStorage } from '../utils/storage';

/**
 * 我的订单页面
 *
 * @author Leivmox
 */
interface OrderProduct {
  pid: string;
  name: string;
  rule: string;
  small_img: string;
  price: number | string;
  count: number;
  enname?: string;
}

interface OrderItem {
  oid: string;
  status: number;
  createdAt: string;
  count: number;
  total: string;
  products: OrderProduct[];
}

@Entry
@Component
struct MyOrders {
  @StorageLink('token') token: string = '';
  @State currentStatus: number = 0;
  @State orderList: OrderItem[] = [];
  @State isLoading: boolean = false;
  private tabs: string[] = ['全部', '进行中', '已完成'];

  async aboutToAppear() {
    let context = getContext(this);
    try {
      let localToken = await getStorage("user_token", context);
      if (localToken) {
        this.token = localToken.toString();
        AppStorage.setOrCreate('token', this.token);
      }
    } catch (e) {
    }

    if (this.token) {
      this.getOrderList();
    } else {
      setTimeout(() => {
        if (!this.token) {
          promptAction.showToast({ message: '请先登录' });
        }
      }, 500);
    }
  }


  async getOrderList() {
    if (!this.token) {
      return;
    }
    this.isLoading = true;

    try {
      let res = await findOrder(this.token, this.currentStatus);

      let resData: Record<string, Object>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result);
      } else {
        resData = res.result as Record<string, Object>;
      }

      let list: Array<Record<string, Object>> = [];
      if (Array.isArray(resData.result)) {
        list = resData.result as Array<Record<string, Object>>;
      } else if (Array.isArray(resData.data)) {
        list = resData.data as Array<Record<string, Object>>;
      } else if (Array.isArray(resData.orderList)) {
        list = resData.orderList as Array<Record<string, Object>>;
      }

      let orderMap = new Map<string, OrderItem>();

      list.forEach((item: Record<string, Object>) => {
        let oid = (item.oid || item.id || '').toString();

        let priceStr = (item.price || '0').toString();
        let countVal = (item.count as number) || 1;
        let lineTotal = parseFloat(priceStr) * countVal;

        let product: OrderProduct = {
          pid: (item.pid || item.id || '').toString(),
          name: (item.name || '未知商品').toString(),
          rule: (item.rule || '').toString(),
          small_img: (item.smallImg || item.small_img || '').toString(),
          price: priceStr,
          count: countVal,
          enname: (item.enname || '').toString()
        };

        if (orderMap.has(oid)) {
          let existingOrder = orderMap.get(oid)!;
          existingOrder.products.push(product);
          existingOrder.count += countVal;

          let currentTotal = parseFloat(existingOrder.total) + lineTotal;
          existingOrder.total = currentTotal.toFixed(2);

        } else {
          let newOrder: OrderItem = {
            oid: oid,
            status: item.status as number,
            createdAt: (item.createdAt || '').toString(),
            count: countVal,
            total: lineTotal.toFixed(2),
            products: [product]
          };
          orderMap.set(oid, newOrder);
        }
      });

      this.orderList = Array.from(orderMap.values());

    } catch (err) {
      promptAction.showToast({ message: '数据加载失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async handleConfirm(oid: string) {
    try {
      await confirmReceive(this.token, oid);
      promptAction.showToast({ message: '已收货' });
      this.getOrderList();
    } catch (e) {
    }
  }

  async handleDelete(oid: string) {
    promptAction.showDialog({
      title: '提示',
      message: '确定删除？',
      buttons: [{ text: '取消', color: '#666' }, { text: '删除', color: 'red' }]
    })
      .then(async (resp) => {
        if (resp.index === 1) {
          await removeOrder(this.token, oid);
          this.getOrderList();
        }
      })
  }

  @Builder
  OrderCard(item: OrderItem) {
    Column() {
      Text("订单信息")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')
        .margin({ bottom: 10 })

      Row() {
        Text(`订单编号: ${item.oid}`).fontSize(13).fontColor('#999').layoutWeight(1)
        if (item.status === 1) {
          Text("确认收货")
            .fontSize(13)
            .fontColor('#0C34BA')
            .fontWeight(FontWeight.Medium)
            .onClick(() => this.handleConfirm(item.oid))
        } else if (item.status === 2) {
          Row() {
            Text("已完成")
              .fontSize(14)
              .fontColor('#666')
              .margin({ right: 10 })
            Image($r('app.media.del'))
              .width(16)
              .height(16)
              .onClick(() => this.handleDelete(item.oid))
          }
        }
      }
      .width("100%").justifyContent(FlexAlign.SpaceBetween).padding({ bottom: 15 })

      Column() {
        ForEach(item.products, (prod: OrderProduct) => {
          Row() {
            Image(prod.small_img)
              .width(60)
              .height(60)
              .borderRadius(4)
              .backgroundColor('#f5f5f5')
              .objectFit(ImageFit.Cover)

            Column({ space: 5 }) {
              Row() {
                Text(prod.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(prod.rule)
                  .fontSize(12)
                  .fontColor('#999')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ left: 10 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Bottom)

              Text(prod.enname)
                .fontSize(12)
                .fontColor('#999')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .width('100%')

              Row() {
                Text(`￥${prod.price}`)
                  .fontSize(14)
                  .fontColor('#E60012')
                  .fontWeight(FontWeight.Bold)
                  .layoutWeight(1)

                Text(`x${prod.count}`)
                  .fontSize(12)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .layoutWeight(1)
            .padding({ left: 10 })
            .height(60)
            .justifyContent(FlexAlign.SpaceBetween)

          }
          .width("100%")
          .margin({ bottom: 15 })
        })
      }
      .width("100%")

      Divider().color('#f5f5f5').strokeWidth(1).margin({ bottom: 10 })

      Text(item.createdAt.replace('T', ' ').substring(0, 19))
        .fontSize(13).fontColor('#454545').width('100%').margin({ bottom: 8 })

      Row() {
        Text(`共计 ${item.count} 件商品`).fontSize(13).fontColor('#666')
        Row() {
          Text("订单金额: ").fontSize(16).fontColor('#E60012').fontWeight(FontWeight.Bold)
          Text(`￥${item.total}`).fontSize(16).fontColor('#E60012').fontWeight(FontWeight.Bold)
        }
      }
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width("95%")
    .backgroundColor(Color.White)
    .borderRadius(12)
    .padding(15)
    .margin({ bottom: 15 })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text("< 返回").fontColor('#0C34BA').fontSize(16)
        }
        .height('100%').onClick(() => {
          router.back()
        }).padding({ left: 15 })

        Text("我的订单")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ right: 60 })
      }
      .width("100%").height(56).backgroundColor(Color.White).zIndex(99)

      Stack({ alignContent: Alignment.Top }) {

        Column().width('100%').height(130).backgroundColor('#0C34BA')

        Column() {

          Row() {
            ForEach(this.tabs, (item: string, index: number) => {
              Column() {
                Text(item)
                  .fontSize(15)
                  .fontWeight(this.currentStatus === index ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.currentStatus === index ? '#0C34BA' : '#666')
                  .margin({ bottom: 8 })
                if (this.currentStatus === index) {
                  Row().width(25).height(3).backgroundColor('#0C34BA').borderRadius(2)
                } else {
                  Row().width(25).height(3).backgroundColor(Color.Transparent)
                }
              }
              .layoutWeight(1).justifyContent(FlexAlign.Center).height("100%")
              .onClick(() => {
                this.currentStatus = index;
                this.getOrderList();
              })
            })
          }
          .width('95%')
          .height(60)
          .backgroundColor(Color.White)
          .borderRadius({
            topLeft: 12,
            topRight: 12,
            bottomLeft: 0,
            bottomRight: 0
          })
          .margin({ top: 90 })
          if (this.isLoading && this.orderList.length === 0) {
            Text("加载中...").fontColor('#999').margin({ top: 40 })
          } else if (this.orderList.length === 0) {
            Column() {
              Image($r('app.media.Null')).width(80).height(80).opacity(0.5).margin({ bottom: 10 })
              Text("暂无订单").fontColor('#999')
            }.width('100%').height(200).justifyContent(FlexAlign.Center)
          } else {
            List() {
              ForEach(this.orderList, (item: OrderItem) => {
                ListItem() {
                  this.OrderCard(item)
                }
              })
            }
            .width("100%")
            .layoutWeight(1)
            .margin({ top: 15 })
            .scrollBar(BarState.Off)
            .alignListItem(ListItemAlign.Center)
          }

        }
        .width('100%')
        .height('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width("100%").height("100%")
  }
}
