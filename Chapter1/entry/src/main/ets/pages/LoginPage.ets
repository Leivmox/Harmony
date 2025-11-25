@Entry
@Component
struct LoginPage {
  @State message: string = "Hello World!";
  @Builder
  myPhoneInput(){
    Row({space:25}){
      Text("手机号").width(50)
      TextInput({placeholder:"手机号"})
        .type(InputType.PhoneNumber)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
    }
    .myInputStyle()
  }

  @Styles
  myInputStyle(){
    .margin({left:10,right:10})
    .padding({bottom:5})
    .border({
      width: { bottom:1 },
      style:BorderStyle.Solid,
      color:"#ddd"
    })
  }
  build() {
    Column() {
      Row() {
        Image($r("app.media.home_active"))
          .width(50)
          .height(50)
        Text("Luckin_Coffee")
          .layoutWeight(1)
          .fontWeight(FontWeight.Bold)
        Text("巴巴博一")
          .fontColor($r("app.color.theme_color"))
          .fontWeight(FontWeight.Bold)
      }

      .padding({
        left: 20,
        right: 20
      })

      Column({ space: 30 }) {
        Text("欢迎回来！")
          .fontSize(40)
        Text("Please login to your accounts")
          .fontSize(18)
          .fontColor(Color.Gray)
      }
      .width("100%")
      .margin({
        top: 80,
        bottom: 80
      })
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: 10,
        right: 10

      })
      // .backgroundColor(Color.Pink)

    Column(){
      this.myPhoneInput()

      Row({space:25}){
        Text("密码").width(50)
        TextInput({placeholder:"密码"})
          .type(InputType.Password)
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
      }
          .myInputStyle()
    Text("忘记密码？")
      .width("100%")
      .margin({top:20})
      .textAlign(TextAlign.End)
      .fontColor(Color.Gray)
    Button("登录")
      .width("100%")
      .height(50)
      .margin({ top: 50 })
      .borderRadius(25)
      .background(Color.White)
      .onClick((even:ClickEvent)=>{ })
      Button("注册")
        .width("100%")
        .height(50)
        .margin({ top: 20 })
        .backgroundColor(Color.White)
        .fontColor("#888")
        .border({
          width:1,
          color:"#ddd"
        })
        .borderRadius(25)
        .onClick((even:ClickEvent)=>{ })

    }

  }
  }
}