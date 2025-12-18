import { router, promptAction } from '@kit.ArkUI';
import { getStorage } from '../utils/storage';
import { findAllLike, toggleLike } from '../api/api';
import { productItem } from '../model/model';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct MyCollect {
  @State collectList: productItem[] = [];
  @State user_token: string = "";
  @State isLoading: boolean = false;

  aboutToAppear() {
    let token = getStorage("user_token");
    this.user_token = token ? token.toString() : "";

    if (!this.user_token) {
      promptAction.showToast({ message: "您还未登录" });
    } else {
      this.getCollectData();
    }
  }

  getCollectData() {
    this.isLoading = true;
    findAllLike(this.user_token)
      .then(res => {
        let resStr = "";
        if (typeof res.result === 'string') {
          resStr = res.result;
        } else {
          resStr = JSON.stringify(res.result);
        }

        let resJson = JSON.parse(resStr) as Record<string, Object>;
        let rawList = resJson['result'] as Record<string, Object>[];

        if (rawList && rawList.length > 0) {
          this.collectList = rawList.map((item) => {
            let imgPath = (item['smallImg'] || item['small_img']) as string;
            let cleanItem: productItem = {
              pid: item['pid'] as string,
              name: item['name'] as string,
              enname: item['enname'] as string,
              price: item['price'] as string,
              smallImg: imgPath
            } as productItem;
            return cleanItem;
          });
        } else {
          this.collectList = [];
        }
      })
      .catch((err: BusinessError) => {
        console.error("获取收藏失败:", JSON.stringify(err));
        promptAction.showToast({ message: "网络请求失败" });
      })
      .finally(() => {
        this.isLoading = false;
      })
  }

  removeItem(pid: string, index: number) {
    AlertDialog.show({
      title: '提示',
      message: '确定要取消收藏该商品吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: () => {
          toggleLike(true, pid, this.user_token)
            .then(res => {
              this.collectList.splice(index, 1);
              promptAction.showToast({ message: "已移除" });
            })
            .catch((err: BusinessError) => {
              promptAction.showToast({ message: "操作失败" });
            })
        }
      }
    })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text("< 返回")
            .fontColor('#0C34BA')
            .fontSize(16)
        }
        .height('100%')
        .onClick(() => {
          router.back();
        })
        .padding({ left: 15 })

        Text("我的收藏")
          .fontSize(18)
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ right: 60 })
      }
      .width("100%")
      .height(56)
      .backgroundColor(Color.White)
      .zIndex(2)

      Stack({ alignContent: Alignment.Top }) {

        Column()
          .width('100%')
          .height(130)
          .backgroundColor('#0C34BA')

        Column() {
          Scroll() {
            Column() {
              if (!this.isLoading && this.collectList.length === 0) {
                Column({ space: 15 }) {
                  Image($r('app.media.Null'))
                    .width(120)
                    .objectFit(ImageFit.Contain)

                  Text("没有收藏数据!")
                    .fontColor('#999')
                    .fontSize(15)
                }
              }
              else {
                Flex({
                  wrap: FlexWrap.Wrap,
                  justifyContent: FlexAlign.SpaceBetween
                }) {
                  ForEach(this.collectList, (item: productItem, index: number) => {
                    Column() {
                      Image(item.smallImg)
                        .width("100%")
                        .height(120)
                        .objectFit(ImageFit.Contain)
                        .margin({ bottom: 8 })
                        .onClick(() => {
                          router.pushUrl({
                            url: "pages/DetailPage",
                            params: { pid: item.pid }
                          })
                        })

                      Text(item.name)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#333')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')

                      Text(item.enname)
                        .fontSize(10)
                        .fontColor('#999')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .width('100%')
                        .margin({ bottom: 8 })

                      Row() {
                        Text("￥" + item.price)
                          .fontSize(14)
                          .fontColor('#D43C33')
                          .fontWeight(FontWeight.Bold)

                        Image($r("app.media.del"))
                          .width(18)
                          .height(18)
                          .opacity(0.6)
                          .onClick(() => {
                            this.removeItem(item.pid, index)
                          })
                      }
                      .width('100%')
                      .justifyContent(FlexAlign.SpaceBetween)
                    }
                    .width("48%")
                    .backgroundColor('#F9F9F9')
                    .borderRadius(8)
                    .padding(8)
                    .margin({ bottom: 10 })
                  })
                }
              }
            }
            .width('100%')
            .constraintSize({ minHeight: '100%' })
            .justifyContent(this.collectList.length === 0 ? FlexAlign.Center : FlexAlign.Start)
            .alignItems(this.collectList.length === 0 ? HorizontalAlign.Center : HorizontalAlign.Start)
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .align(Alignment.Top)
        }
        .width('95%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding(15)
        .margin({ top: 90, bottom: 20 })
        .layoutWeight(1)

      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
}
