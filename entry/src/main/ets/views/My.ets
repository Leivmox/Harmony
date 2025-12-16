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
      // 【新增代码】根据点击的标题跳转
      if (title === "我的收藏") {
        router.pushUrl({ url: "pages/MyCollect" })
      } else if (title === "个人资料") {
        router.pushUrl({ url: "pages/PersonalInfo" })
      }
      // 可以在这里加其他的跳转，比如 "地址管理" 等
    })
    // 列表项背景透明
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
        // ===============================================
        // 【修改点 1】 底层：背景图 (luckin_bg.jpg)
        // ===============================================
        Image($r('app.media.luckin_bg'))
          .width('100%')
          .height(235)
          // 保持比例覆盖，防止图片变形
          .objectFit(ImageFit.Cover)

        // 上层：半透明内容卡片
        Column() {
          // --- A. 用户信息头部 ---
          Row() {
            // ===============================================
            // 【修改点 2】 头像 (luckin.png)
            // ===============================================
            Image($r('app.media.luckin'))
              .width(70)
              .height(70)
              // 设置圆角为宽高的一半，强制变圆
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
          .padding({ top: 20, bottom: 30, left: 10, right: 10 })
          .onClick(() => {
            // 点击头部依然可以跳转登录（如果需要的话）
            router.pushUrl({ url: "pages/LoginPage" })
          })

          // --- B. 功能列表 ---
          Column() {
            ForEach(this.menuList, (item: string, index: number) => {
              this.SettingCell(item, index !== this.menuList.length - 1)
            })
          }
        }
        .width('95%')
        // 半透明背景
        .backgroundColor('rgba(255, 255, 255, 0.8)')
        // 毛玻璃效果(可选，会让背景图透过来时更好看)
        .backdropBlur(10)
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
