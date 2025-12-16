import { router } from '@kit.ArkUI';
// 1. 导入读取缓存的工具
import { getStorage } from '../utils/storage';

@Entry
@Component
struct PersonalInfo {

  // 2. 将初始值设为空，等待从缓存加载
  @State userInfo: Record<string, string> = {
    "id": "",
    "phone": "",
    "nickname": "康刘勇", // 昵称暂时保持静态，如果登录也存了昵称这里也可以改
    "intro": "2022与你相约在粤嵌，爱你呦么么哒"
  };

  // 3. 页面加载时执行：从本地存储获取数据
  aboutToAppear() {
    let context = getContext(this);

    // --- 获取手机号 ---
    // 注意：key必须和 LoginPage 里 saveStorage 用的 key 一致 ("user_phone")
    let savedPhone = getStorage("user_phone", context);
    if (savedPhone) {
      this.userInfo['phone'] = savedPhone.toString();
    } else {
      this.userInfo['phone'] = "未绑定"; // 没取到的默认值
    }

    // --- 获取用户ID ---
    // 注意：key必须和 LoginPage 里 saveStorage 用的 key 一致 ("user_id")
    let savedId = getStorage("user_id", context);
    if (savedId) {
      this.userInfo['id'] = savedId.toString();
    } else {
      this.userInfo['id'] = "未登录"; // 没取到的默认值
    }
  }

  build() {
    Column() {
      // ============================================================
      // 1. 顶部导航栏 (保持不变)
      // ============================================================
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

      // ============================================================
      // 2. 下方层叠区域
      // ============================================================
      Stack({ alignContent: Alignment.Top }) {

        // (A) 蓝色背景填充
        Column()
          .width('100%')
          .height(180)
          .backgroundColor('#0C34BA')

        // (B) 核心内容大框 (白色卡片)
        Column() {
          Scroll() {
            Column() {
              // --- 1. 头像行 ---
              Row() {
                Text("头像")
                  .fontSize(15)
                  .fontColor('#333')

                Image($r('app.media.luckin')) // 确保此处有图片资源
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

              // --- 2. 用户ID (动态显示) ---
              Row() {
                Text("用户id")
                  .fontSize(15)
                  .fontColor('#333')

                // 这里使用的是 state 中读取到的数据
                Text(this.userInfo['id'])
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ top: 20, bottom: 20 })

              Divider().color('#F5F5F5').strokeWidth(1)

              // --- 3. 手机号 (动态显示) ---
              Row() {
                Text("手机号")
                  .fontSize(15)
                  .fontColor('#333')

                // 这里使用的是 state 中读取到的数据
                Text(this.userInfo['phone'])
                  .fontSize(14)
                  .fontColor('#999')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .padding({ top: 20, bottom: 20 })

              Divider().color('#F5F5F5').strokeWidth(1)

              // --- 4. 昵称 ---
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

              // --- 5. 简介 ---
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
