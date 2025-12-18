import { router, promptAction, PromptAction } from '@kit.ArkUI';
import { login } from '../api/api';
import { saveStorage, getStorage } from '../utils/storage';
import { validForm } from '../utils/validform';
import { userMsg } from '../model/model';

interface ResultData {
  code: number;
  msg: string;
  token?: string;
}
interface ApiResponse {
  result: ResultData;
}

@Entry
@Component
struct SafetyCenter {
  @State isShowSheet: boolean = false;
  @State oldPassword: string = "";
  @State newPassword: string = "";

  private promptAction: PromptAction = this.getUIContext().getPromptAction();

  performLogout(msg: string) {
    let context = getContext(this);
    saveStorage("user_token", "", context);

    this.promptAction.showToast({ message: msg });

    setTimeout(() => {
      router.replaceUrl({ url: "pages/LoginPage" })
        .then(() => {
          console.info('跳转登录页成功');
        })
        .catch((err: object) => {
          console.error('跳转失败，请检查 pages/LoginPage 是否在 main_pages.json 中配置', JSON.stringify(err));
        })
    }, 1000)
  }

  handleLogout() {
    AlertDialog.show({
      title: '提示',
      message: '确定要退出登录吗？',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '确定',
        fontColor: Color.Red,
        action: () => {
          this.performLogout("已退出登录");
        }
      }
    })
  }

  handleSubmitChange() {
    if (this.oldPassword === "" || this.newPassword === "") {
      this.promptAction.showToast({ message: "密码不能为空" });
      return;
    }

    let checkData = {
      password: {
        val: this.newPassword,
        regexpRule: new RegExp("^[A-Za-z]\\w{5,15}$"),
        errMsg: "新密码格式错误: 字母开头, 6-16位"
      }
    } as userMsg;

    if (!validForm(checkData, this.promptAction)) {
      return;
    }

    let context = getContext(this);
    let phone = getStorage("user_phone", context) as string;

    if (!phone) {
      this.performLogout("登录信息已失效，请重新登录");
      return;
    }

    login(phone, this.oldPassword)
      .then((res: object) => {
        let response = res as ApiResponse;

        if (response.result.code == 200) {
          console.log("旧密码验证通过");


          this.isShowSheet = false;

          this.performLogout("修改成功，请重新登录");

        } else {
          this.promptAction.showToast({
            message: response.result.msg || "旧密码错误，请检查"
          });
        }
      })
      .catch((err: object) => {
        console.log("请求失败:", JSON.stringify(err));
        this.promptAction.showToast({ message: "网络连接失败" });
      })
  }

  @Builder
  PasswordInputItem(label: string, val: string, onValChange: (val: string) => void) {
    Row() {
      Text(label).fontSize(16).fontColor('#333').width(80)
      TextInput({ placeholder: "请输入" + label, text: val })
        .type(InputType.Password)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .placeholderColor('#999')
        .onChange(onValChange)
    }
    .height(60)
    .width('100%')
    .border({ width: { bottom: 1 }, color: '#F5F5F5' })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  ChangePasswordSheetBuilder() {
    Column() {
      Row() {
        Text("修改密码").fontSize(20).fontColor('#333').fontWeight(FontWeight.Medium)
        Text("×").fontSize(28).fontColor('#999').onClick(() => { this.isShowSheet = false })
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 20 })

      Column() {
        this.PasswordInputItem("旧密码", this.oldPassword, (val) => { this.oldPassword = val })
        this.PasswordInputItem("新密码", this.newPassword, (val) => { this.newPassword = val })
      }
      .margin({ bottom: 40 })

      Button("确认修改")
        .width('100%').height(50).backgroundColor('#0C34BA').fontColor(Color.White)
        .fontSize(18).borderRadius(25)
        .onClick(() => {
          this.handleSubmitChange();
        })
    }
    .padding(20).width('100%').height('100%').backgroundColor(Color.White)
  }

  @Builder
  SettingItem(title: string, isLast: boolean = false) {
    Row() {
      Text(title).fontSize(16).fontColor('#333333')
      Blank()
      Text('>').fontSize(18).fontColor('#999999')
    }
    .width('100%').height(55).alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (title === "修改密码") {
        this.oldPassword = "";
        this.newPassword = "";
        this.isShowSheet = true;
      } else if (title === "注销账号") {
        this.promptAction.showToast({ message: "请联系客服注销" })
      }
    })
    if (!isLast) {
      Divider().color('#F5F5F5').strokeWidth(1)
    }
  }

  build() {
    Column() {
      Row() {
        Row() { Text("< 返回").fontColor('#0C34BA').fontSize(16) }
        .height('100%').onClick(() => { router.back() }).padding({ left: 15 })
        Text("安全中心").fontSize(18).fontColor('#333').fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }
      .width("100%").height(56).backgroundColor(Color.White).zIndex(2)

      Stack({ alignContent: Alignment.Top }) {
        Column().width('100%').height(130).backgroundColor('#0C34BA')
        Column() {
          Column() {
            this.SettingItem("修改密码", false)
            this.SettingItem("注销账号", true)
          }
          .width('100%').backgroundColor(Color.White).borderRadius(12).padding({ left: 15, right: 15 })
          Button("退出登录")
            .width('100%').height(50).fontSize(16).fontColor(Color.White)
            .backgroundColor('#0C34BA').borderRadius(25).margin({ top: 100 })
            .onClick(() => { this.handleLogout() })
        }
        .width('95%').margin({ top: 90, bottom: 20 })
      }
      .layoutWeight(1).backgroundColor('#F5F5F5')
    }
    .width('100%').height('100%')
    .bindSheet($$this.isShowSheet, this.ChangePasswordSheetBuilder(), {
      height: 350,
      showClose: false,
      backgroundColor: Color.White
    })
  }
}
