import { router } from '@kit.ArkUI';
import { getStorage } from '../utils/storage';

@Entry
@Component
struct PersonalInfo {

  @State userInfo: Record<string, string> = {
    "id": "",
    "phone": "",
    "nickname": "康刘勇",
    "intro": "2022与你相约在粤嵌，爱你呦么么哒"
  };

  aboutToAppear() {
    let context = getContext(this);

    let savedPhone = getStorage("user_phone", context);
    if (savedPhone) {
      this.userInfo['phone'] = savedPhone.toString();
    } else {
      this.userInfo['phone'] = "未绑定";
    }

    let savedId = getStorage("user_id", context);
    if (savedId) {
      this.userInfo['id'] = savedId.toString();
    } else {
      this.userInfo['id'] = "未登录";
    }
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

        Text("个人资料")
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
              Row() {
                Text("头像")
                  .fontSize(15)
                  .fontColor('#333')

                Image($r('app.media.luckin'))
                  .width(50)
                  .height(50)
                  .borderRadius(25)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor('#eee')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ top: 10, bottom: 10 })

              Divider().color('#F5F5F5').strokeWidth(1)

              Row() {
                Text("用户id")
                  .fontSize(15)
                  .fontColor('#333')

                Text(this.userInfo['id'])
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ top: 20, bottom: 20 })

              Divider().color('#F5F5F5').strokeWidth(1)

              Row() {
                Text("手机号")
                  .fontSize(15)
                  .fontColor('#333')

                Text(this.userInfo['phone'])
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ top: 20, bottom: 20 })

              Divider().color('#F5F5F5').strokeWidth(1)

              Row() {
                Text("昵称")
                  .fontSize(15)
                  .fontColor('#333')

                Text(this.userInfo['nickname'])
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ top: 20, bottom: 20 })

              Divider().color('#F5F5F5').strokeWidth(1)

              Column({ space: 10 }) {
                Text("简介")
                  .fontSize(15)
                  .fontColor('#333')
                  .width('100%')

                Text(this.userInfo['intro'])
                  .fontSize(14)
                  .fontColor('#999')
                  .width('100%')
                  .lineHeight(20)
              }
              .width('100%')
              .padding({ top: 20, bottom: 20 })
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .align(Alignment.Top)
        }
        .width('95%')
        .backgroundColor(Color.White)
        .borderRadius(12)
        .padding({ left: 15, right: 15, top: 5, bottom: 20 })
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
