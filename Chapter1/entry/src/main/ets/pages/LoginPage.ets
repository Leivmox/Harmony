import { userMsg } from '../model/model';
import { vaildForm } from '../utils/validform';
//导入及时反馈模块
import { PromptAction } from '@kit.ArkUI';
import { request } from '../api/request';
//导入测试网络请求模块
import { hitokoto, login, register } from '../api/api';

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
  @State message: string = "Hello World!";
  //登录表单的用户信息
  @State userPhone: string = "13333333333";
  @State userPassword: string = "a12345";
  //注册表单的用户信息
  @State regPhone: string = "13333333333";
  @State regPassword: string = "a12345";
  @State regNickName: string = "11";
  // 1. 定义一个是否显示注册模态转场: @State 状态变量，初始为 false (隐藏)
  @State showSheet: boolean = false;


  // let promptAction:PromptAction = this.getUIContest();

  //创建及时反馈
  private promptAction:PromptAction = this.getUIContext().getPromptAction();

  // //自定义构建函数
  // @Builder
  // myPhoneInput() {
  //   Row({ space: 25 }) {
  //     Text("手机号").width(50)
  //     TextInput({ placeholder: "手机号" })
  //       .type(InputType.PhoneNumber)
  //       .layoutWeight(1)
  //       .backgroundColor(Color.Transparent)
  //   }
  //   .myInputStyle()
  // }

  //自定义构建函数
  @Builder
  myInput(label: string, val: string, type: InputType, fn: (value: string) => void) {
    Row({ space: 25 }) {
      Text(label).width(50)
      TextInput({ placeholder: label, text: val })
        .type(type)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .onChange(fn)
    }
    .myInputStyle()
  }

  //半模态转场内容
  @Builder
  customSheet() {
    Column() {
      Row() {
        Text("注册")
          .fontSize(30)
        Text("×")
          .fontSize(20)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        this.myInput("手机号", this.regPhone, InputType.PhoneNumber, (val) => {
          this.regPhone = val;
        })
        this.myInput("密码", this.regPassword, InputType.Password, (val) => {
          this.regPassword = val;
        })
        this.myInput("昵称", this.regNickName, InputType.Normal, (val) => {
          this.regNickName = val;
        })
      }
      .margin({
        top: 30
      })

      //半模态页面的底部注册按钮
      Button("注册")
        .width("100%")
        .margin({ top: 40 })
        .onClick((event: ClickEvent) => {
          console.log("手机号.密码,昵称=>", this.regPhone, this.regPassword, this.regNickName)



          // //接口:约束对象格式
          // interface userMsg {
          //   phone: rule,
          //   password: rule,
          //   nickname: rule
          //
          // }
          //
          // //定义一个接口,
          // interface rule {
          //   val: string, //当前属性原本的值
          //   regexpRule: RegExp, //当前属性的匹配规则
          //   errMsg: string //当前属性的错误信息(验证不通过的提示)
          // }

          //构建一个 用户注册信息的对象 用于表单验证
          let reg_user_msg: userMsg = {
            phone: {
              val: this.regPhone,
              regexpRule: new RegExp("^1[3-9]\\d{9}$"),
              errMsg: "手机号格式不正确"
            },
            password: {
              val: this.regPassword,
              regexpRule: new RegExp("^[A-Za-z]\\w{5,15}$"),
              errMsg: "密码格式不正确,需以字母开头,包含字母数字和下划线,6~16位",
            },
            nickname: {
              val: this.regNickName,
              regexpRule: new RegExp("^[\\w\u4e00-\u9fa5]{1,10}$"),
              errMsg: "昵称格式不正确, 需字母中文或下划线,长度1~10位",
            }
          }

          // //开始验证
          // //获取对象的 key,确定要验证的输入框
          // let keys: string[] = Object.keys(reg_user_msg); //拿到了对象键名的字符串数组
          //
          // //假设所有表单都验证通过
          // let flag: boolean = true;
          //
          // for (const item of keys) {
          //   // console.log("对象的键名=> ", item);
          //
          //   // console.log("当前属性的值", JSON.stringify(Object(reg_user_msg)[item]));
          //
          //   //拿到当前属性的值(子对象)
          //   let obj: rule = Object(reg_user_msg)[item];
          //
          //   //验证值是否符合规则  => 语法:正则.test("要验证的值")
          //   if (!obj.regexpRule.test(obj.val)) {
          //     //某个输入框不通过,输出当前错误信息,flag假设不成立,跳出循环
          //     console.log(obj.errMsg);
          //     flag = false;
          //     break;
          //   }
          // }
          // if(flag){
          //   console.log("表单验证通过")
          //   //真正的注册逻辑
          // }


          // this.promptAction.showToast({
          //   message:"测试吐司"
          // })

          let vaild_result: boolean = vaildForm(reg_user_msg, this.promptAction)
          if (vaild_result) {
            //真正的注册功能
            register(this.regPhone,this.regPassword,this.regNickName)
              .then(res=>{
                console.log("注册的结果 =>",JSON.stringify(res.result))
                this.promptAction.showToast({
                  message: Object(res).result.msg
                })
                if(Object(res).result.code == 100){
                  this.showSheet = false;
                }
              })
              .catch((err:object)=>{
                console.log("失败 =>",JSON.stringify(err))
              })
          }

        })


    }
    .padding(20)
  }

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

      //登录表单
      Column() {
        // this.myPhoneInput()

        this.myInput("手机号", this.userPhone, InputType.PhoneNumber, (val) => {
          this.userPhone = val;
        })
        this.myInput("密码", this.userPassword, InputType.Password, (val) => {
          this.userPassword = val;
        })

        // Row({ space: 25 }) {
        //   Text("密码").width(50)
        //   TextInput({ placeholder: "密码" })
        //     .type(InputType.Password)
        //     .layoutWeight(1)
        //     .backgroundColor(Color.Transparent)
        // }
        // .myInputStyle()

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
          .background(Color.White)
          .onClick((even: ClickEvent) => {
            console.log("点击登录");
            //登录功能
            //构建一个 用户登录信息的对象 用于表单验证
            let login_user_msg: userMsg = {
              phone: {
                val: this.userPhone,
                regexpRule: new RegExp("^1[3-9]\\d{9}$"),
                errMsg: "手机号格式不正确"
              },
              password: {
                val: this.userPassword,
                regexpRule: new RegExp("^[A-Za-z]\\w{5,15}$"),
                errMsg: "密码格式不正确,需以字母开头,包含字母数字和下划线,6~16位",
              }

            }

            //开始验证
            let vaild_result: boolean = vaildForm(login_user_msg, this.promptAction)
            //调用登录接口
            if (vaild_result) {
              //真正的登录逻辑


            }
          })
        Button("注册")
          .width("100%")
          .height(50)
          .margin({ top: 20 })
          .backgroundColor(Color.White)
          .fontColor("#888")
          .border({
            width: 1,
            color: "#ddd"
          })
          .borderRadius(25)
          .onClick((even: ClickEvent) => {
            this.showSheet = true;
          })
          // .bindSheet(true, this.customSheet(), {
          .bindSheet($$this.showSheet, this.customSheet(), {
            height: "50%",
            showClose: false
          })

      }

    }
  }
}