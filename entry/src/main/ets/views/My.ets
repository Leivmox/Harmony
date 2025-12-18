//自定义组件 -- 我的
import { router } from '@kit.ArkUI';

@Component
export default struct My {
  @State menuList: string[] = [
    "个人资料",
    "我的订单",
    "我的收藏",
    "地址管理",
    "安全中心"
  ]

  @Builder
  SettingCell(title: string, showBorder: boolean) {
    Row() {
      Text(title).fontSize(16).fontColor('#333333')
      Blank()
      Text('>').fontSize(18).fontColor('#999999')
    }
    .width('100%')
    .height(55)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      console.info(`点击了: ${title}`)
      if (title === "我的收藏") {
        router.pushUrl({ url: "pages/MyCollect" })
      } else if (title === "个人资料") {
        router.pushUrl({ url: "pages/PersonalInfo" })
      } else if (title === "安全中心") {
        router.pushUrl({ url: "pages/SafetyCenter" })
      } else if (title === "地址管理") {
        router.pushUrl({ url: "pages/AddressManage" })
      }
    })
    .backgroundColor(Color.Transparent)

    if (showBorder) {
      Divider()
        .color('#F0F0F0')
        .strokeWidth(1)
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.luckin_bg'))
          .width('100%')
          .height(235)
          .objectFit(ImageFit.Cover)

        Column() {
          Row() {
            Image($r('app.media.luckin'))
              .width(70)
              .height(70)
              .borderRadius(35)
              .objectFit(ImageFit.Cover)
              .margin({ right: 15 })

            Column({ space: 8 }) {
              Text("康刘勇")
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#3D59AB')
              Text("2022与你相约在粤嵌，爱你呦么么哒")
                .fontSize(13)
                .fontColor('#666666')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({
            top: 20,
            bottom: 30,
            left: 10,
            right: 10
          })

          .onClick(() => {
            router.pushUrl({ url: "pages/TestToken" })
          })

          Column() {
            ForEach(this.menuList, (item: string, index: number) => {
              this.SettingCell(item, index !== this.menuList.length - 1)
            })
          }
        }
        .width('95%')
        .backgroundColor('rgba(255, 255, 255, 1)')
        .borderRadius(12)
        .shadow({ radius: 10, color: '#1A000000', offsetY: 5 })
        .padding({ left: 15, right: 15, bottom: 10 })
        .margin({ top: 190 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
