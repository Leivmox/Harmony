//导入数据格式
import { userMsg } from '../model/model';
//导入表单验证模块
import { validForm } from '../utils/validform';
//导入及时反馈模/块
import { PromptAction, router } from '@kit.ArkUI';
//导入注册,登录接口
import { login, register } from '../api/api';
import { saveStorage } from '../utils/storage';

// //调用网络请求 测试一言
// hitokoto()
//   .then(res=>{
//     console.log("成功=>",JSON.stringify(res.result))
//   })
//   .catch((err:object)=>{
//     console.log("错误=>",JSON.stringify(err))
//   })

@Entry
@Component
struct LoginPage {
  //状态变量：数据变化会驱动视图更新
  //是否显示模态页面转场
  @State isShowSheet: boolean = false;
  //登录表单用户信息
  @State userPhone: string = "13546827857"
  @State userPassword: string = "q12345"
  //注册表单的用户信息
  @State regPhone: string = "13546827857";
  @State regPassword: string = "q12345";
  @State regNickName: string = "zq";
  //创建即使反馈对象
  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  /**
   * @description 自定义构建函数--手机号输入框
   * @param label 输入框的描述
   * @param val 输入框的值
   * @param type 输入框的类型
   * @param fn onCharge实践的回调函数
   */
  @Builder
  myPhoneInput(label: string, val: string, type: InputType, fn: (val: string) => void) {
    Row({ space: 25 }) {
      Text(label).width(50)
      TextInput({ placeholder: label })
        .type(type)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onChange(fn)
    }
    .myInputStyle()
  }

  /**
   * @description 自定义构建函数 -- 半模态页面的内容
   */
  @Builder
  customSheet() {
    Column() {
      //顶部标题
      Row() {
        Text("注册").fontSize(30)
        Text("x").fontSize(20)
      }
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)

      //中间的输入框
      Column() {
        this.myPhoneInput("手机号", this.regPhone, InputType.PhoneNumber, (val) => {
          this.regPhone = val; //输入的手机号赋值给变量 regPhone
        })
        this.myPhoneInput("密码", this.regPassword, InputType.Password, (val) => {
          this.regPassword = val; //输入的密码赋值给变量 regPassword
        })
        this.myPhoneInput("昵称", this.regNickName, InputType.Normal, (val) => {
          this.regNickName = val; //输入的昵称赋值给变量 regNickName
        })
      }.margin({ top: 30 })

      //底部注册按钮
      Button("注册")
        .width("100%")
        .margin({ top: 40 })
        .onClick((event: ClickEvent) => {
          console.log("手机号，密码。昵称 =>", this.regPhone, this.regPassword, this.regNickName)


          //构建一个 用户注册的信息对象  用于表单验证
          let reg_user_msg: userMsg = {
            phone: {
              val: this.regPhone,
              regexpRule: new RegExp("^1[3-9]\\d{9}$"),
              errMsg: "手机号码格式不正确"
            },
            password: {
              val: this.regPassword,
              regexpRule: new RegExp("^[A-Za-z]\\w{5,15}$"),
              errMsg: "密码以字母开头，可以是字母数字下划线，6到16位"
            },
            nickName: {
              val: this.regNickName,
              regexpRule: new RegExp("^[\\w\u4e00-\u9fa5]{1,10}"),
              errMsg: "昵称有字母数字下划线中文，长度1到10位"
            }
          }
          //验证表单(要验证的表单数据对象，即使反馈对象)
          let valid_result: boolean = validForm(reg_user_msg, this.promptAction);

          //如果表单验证通过
          if (valid_result) {
            //真正的注册功能
            register(this.regPhone, this.regPassword, this.regNickName)
              .then(res => {
                console.log("注册的结果是=>", JSON.stringify(res.result))
                //Toast 显示注册结果
                this.promptAction.showToast({
                  message: Object(res).result.msg
                })
                //如果注册成功
                if (Object(res).result.code == 100) {
                  // 关闭模态页面
                  this.isShowSheet = false
                }
              })
              .catch((err: object) => {
                console.log(JSON.stringify(err))
              })
          }
        })
    }
    .padding(20)
  }

  //通用样式封装
  @Styles
  myInputStyle(){
    .margin({ left: 10, right: 10 })
    .padding({ bottom: 5 })
    .border({
      width: { bottom: 1 },
      style: BorderStyle.Solid,
      color: "#ddd"
    })
  }

  build() {
    Column() {
      Row() {
        Image($r("app.media.home_active"))
          .width(50)
          .height(50)

        Text("Luckin Coffee")
          .layoutWeight(1)
          .fontWeight(FontWeight.Bold)

        Text("先逛一逛")
          .fontColor($r("app.color.theme_color"))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            router.pushUrl({
              url: "pages/Index"
            })
          })
      }
      .padding({
        left: 20,
        right: 20
      })


      //欢迎信息
      Column({ space: 30 }) {
        Text("欢迎回来！")
          .fontSize(40)
        Text("Please login to your accounts")
          .fontSize(22)
      }
      .width("100%")
      .margin({ top: 80, bottom: 80 })
      .padding({ left: 10, right: 10 })
      .alignItems(HorizontalAlign.Start)

      //登录表单
      Column() {
        //手机号码
        this.myPhoneInput("手机号", this.userPhone, InputType.PhoneNumber, (val) => {
          this.userPhone = val;
        })

        //密码
        this.myPhoneInput("密码", this.userPassword, InputType.Password, (val) => {
          this.userPassword = val;
        })

        //忘记密码
        Text("忘记密码？")
          .width("100%")
          .margin({ top: 20 })
          .textAlign(TextAlign.End)
          .fontColor(Color.Gray)

        Button("登录")
          .width("100%")
          .height(50)
          .margin({ top: 50 })
          .borderRadius(25)
          .onClick((event: ClickEvent) => {
            //表单验证
            //构建一个 用户注册的信息对象  用于表单验证
            let login_user_msg: userMsg = {
              phone: {
                val: this.userPhone,
                regexpRule: new RegExp("^1[3-9]\\d{9}$"),
                errMsg: "手机号码格式不正确"
              },
              password: {
                val: this.userPassword,
                regexpRule: new RegExp("^[A-Za-z]\\w{5,15}$"),
                errMsg: "密码以字母开头，可以是字母数字下划线，6到16位"
              },
            }
            //开始验证
            let valid_result: boolean = validForm(login_user_msg, this.promptAction);
            //验证通过,调用登录接口
            if (valid_result) {
              //真正的登录逻辑
              login(this.userPhone, this.userPassword)
                .then(res => {
                  console.log("登录接口请求成功=>", JSON.stringify(Object(res).result))

                  //Toast显示登录结果
                  this.promptAction.showToast({
                    message: Object(res).result.msg
                  })
                  //登陆成功
                  if (Object(res).result.code == 200) {

                    // // 【关键修改 1】先保存 Token！
                    // let key: string = "user_token";
                    // let val: string = Object(res).result.token
                    // // 【关键修改】传入 getContext(this) 确保上下文正确
                    // saveStorage(key, val, getContext(this));
                    //
                    // // ====================================================
                    // // 2. 【新增】保存手机号
                    // // ====================================================
                    // // 直接使用 getContext(this)，不要用 context 变量
                    // saveStorage("user_phone", this.userPhone, getContext(this));
                    //
                    // // ====================================================
                    // // 3. 【新增】保存用户ID (生成假ID)
                    // // ====================================================
                    // let fakeId = "coffe" + new Date().getTime();
                    // // 直接使用 getContext(this)
                    // saveStorage("user_id", fakeId, getContext(this));
                    //
                    // // 确保数据写入 Storage
                    // // saveStorage(key, val)
                    // console.log("Token已保存，准备跳转");
                    // 获取后端返回的 token
                    let tokenVal: string = Object(res).result.token;

                    // ====================================================
                    // 【关键修复步骤】
                    // 1. 存入 AppStorage，这是为了让 AddressAdd 页面能通过 @StorageProp('token') 拿到数据
                    // 注意：这里的 Key 必须是 'token'，因为你在 AddressAdd 里写的是 @StorageProp('token')
                    // ====================================================
                    AppStorage.setOrCreate('token', tokenVal);

                    // 2. 持久化存储 (保存到本地文件，下次打开APP还在)
                    // 你的 saveStorage 可能是封装的 Preferences
                    saveStorage("user_token", tokenVal, getContext(this));
                    saveStorage("user_phone", this.userPhone, getContext(this));

                    console.log("Token已写入AppStorage，值:", tokenVal);

                    // 跳转到首页 (或者跳转到测试页)
                    // router.pushUrl({ url: "pages/Index" })
                    // 为了测试，你可以暂时跳到 TestToken 页面，之后改回 Index
                    // router.pushUrl({ url: "pages/TestToken" })

                    //跳转到首页router
                    router.pushUrl({
                      url: "pages/Index"
                    })

                    //持久化存储 登录状态token
                    // let key: string = "user_token";
                    // let val: string = Object(res).result.token
                    // saveStorage(key, val)
                  }
                })
            }
          })
      }

      Button("注册")
        .width("100%")
        .height(50)
        .margin({ top: 50 })
        .borderRadius(25)
        .fontColor("#888")
        .backgroundColor(Color.White)
        .border({
          width: 1,
          color: "#ddd"
        })
        .onClick((event: ClickEvent) => {
          //显示注册页面
          this.isShowSheet = true;
        })
        //半模态转场
        .bindSheet($$this.isShowSheet, this.customSheet(), {
          height: "50%",
          showClose: false
        })
    }
    .padding({ left: 10, right: 10 })
  }
}
