import { router, promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { http } from '@kit.NetworkKit';
// 确保你的 api 文件里导出了 updateDesc
import { findAccountInfo, updateNickName, updateDesc, ApiResponse, UserInfo } from '../api/api';
import { getStorage } from '../utils/storage';

@Entry
@Component
struct PersonalInfo {
  // 1. 获取全局 Token
  @StorageLink('token') token: string = '';

  // 2. 页面显示状态
  @State userId: string = '读取中...';
  @State phone: string = '读取中...';
  @State nickName: string = '加载中...';
  @State intro: string = '加载中...';

  // 3. 弹窗(Sheet)控制状态
  @State isShowSheet: boolean = false;
  @State editType: string = '';      // 'nickname' 或 'intro'
  @State sheetTitle: string = '';    // 弹窗标题
  @State inputValue: string = '';    // 输入框的值

  // =======================================================
  // 生命周期与初始化
  // =======================================================
  aboutToAppear() {
    this.initData();
  }

  async initData() {
    let context = getContext(this);

    // 1. 先读本地缓存 (为了让界面不留白，先显示旧数据)
    try {
      let savedPhone = await getStorage("user_phone", context);
      let savedId = await getStorage("user_id", context);
      this.phone = savedPhone ? savedPhone.toString() : '未绑定';
      this.userId = savedId ? savedId.toString() : '未登录';
    } catch (e) {}

    // 2. 获取 Token (优先内存，其次缓存)
    let finalToken = this.token;
    if (!finalToken) {
      let localToken = await getStorage("user_token", context);
      if (localToken) {
        finalToken = localToken.toString();
        this.token = finalToken;
      }
    }

    if (!finalToken) {
      this.nickName = "未登录";
      this.intro = "请先登录";
      return;
    }

    // 3. 请求最新接口数据
    findAccountInfo(finalToken).then((res) => {
      let resData: ApiResponse<UserInfo[] | UserInfo>;
      // 兼容 JSON 字符串或对象
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as ApiResponse<UserInfo[] | UserInfo>;
      } else {
        resData = res.result as ApiResponse<UserInfo[] | UserInfo>;
      }

      // 宽松判断状态码
      const codeStr = String(resData.code);
      if (['200', 'B001', 'A001', '0', '1'].includes(codeStr)) {
        let user: UserInfo | null = null;
        if (Array.isArray(resData.result)) {
          if (resData.result.length > 0) user = resData.result[0];
        } else {
          user = resData.result as UserInfo;
        }

        if (user) {
          this.nickName = user.nickName || '未设置';
          this.intro = user.desc || '暂无简介';
          if (user.userId) this.userId = user.userId;
          if (user.phone) this.phone = user.phone;
        }
      }
    }).catch((err: BusinessError) => {
      console.error("PersonalInfo: 请求异常", JSON.stringify(err));
    })
  }

  // =======================================================
  // 🔥🔥🔥 核心：保存逻辑 (修复了简介不更新的问题)
  // =======================================================
  saveInfo() {
    console.info(`[Debug] 点击保存: type=${this.editType}, value=${this.inputValue}`);

    // 1. 校验空值
    if (this.inputValue.trim() === '') {
      promptAction.showToast({ message: '内容不能为空' });
      return;
    }

    // 2. 定义成功后的回调 (封装起来，避免代码重复)
    const handleSuccess = () => {
      console.info('[Debug] 修改成功，开始更新UI');

      // A. 关闭弹窗
      this.isShowSheet = false;

      // B. 立即更新界面显示的变量
      if (this.editType === 'nickname') {
        this.nickName = this.inputValue;
      } else if (this.editType === 'intro') {
        // 🔥 之前这里可能漏了，现在明确赋值
        this.intro = this.inputValue;
      }

      // C. 提示与通知
      promptAction.showToast({ message: '修改成功' });
      // 通知 My 页面刷新
      AppStorage.setOrCreate('userInfoUpdated', Date.now());
    };

    // 3. 定义接口响应处理
    const handleResponse = (res: http.HttpResponse) => {
      console.info('[Debug] 接口返回:', JSON.stringify(res));
      try {
        let resData: ApiResponse;
        if (typeof res.result === 'string') {
          resData = JSON.parse(res.result);
        } else {
          resData = res.result as ApiResponse;
        }

        const codeStr = String(resData.code);

        // 宽松判断：包含你遇到的 C001
        if (['200', 'B001', 'A001', 'C001', '0', '1'].includes(codeStr)) {
          handleSuccess();
        } else {
          // 某些接口虽然 code 不对，但 msg 说成功了，也算过
          if (resData.msg && resData.msg.includes('成功')) {
            handleSuccess();
          } else {
            console.warn('[Debug] 业务失败 code:', codeStr);
            promptAction.showToast({ message: resData.msg || '修改失败' });
          }
        }
      } catch (e) {
        console.error('[Debug] 解析异常:', JSON.stringify(e));
        promptAction.showToast({ message: '数据解析错误' });
      }
    };

    // 4. 根据类型调用不同接口
    if (this.editType === 'nickname') {
      updateNickName(this.token, this.inputValue)
        .then(handleResponse)
        .catch((err: BusinessError) => {
          console.error('[Debug] 网络错误:', JSON.stringify(err));
          promptAction.showToast({ message: '网络请求失败' });
        });
    }
    else if (this.editType === 'intro') {
      // 🔥 确保这里调用的是 updateDesc
      updateDesc(this.token, this.inputValue)
        .then(handleResponse)
        .catch((err: BusinessError) => {
          console.error('[Debug] 网络错误:', JSON.stringify(err));
          promptAction.showToast({ message: '网络请求失败' });
        });
    }
  }

  // =======================================================
  // 弹窗与 UI 构建
  // =======================================================

  openEditSheet(type: string) {
    this.editType = type;
    this.isShowSheet = true;

    if (type === 'nickname') {
      this.sheetTitle = "修改昵称";
      // 如果是默认文案，清空输入框方便用户输入
      this.inputValue = (this.nickName === '未设置' || this.nickName === '加载中...') ? '' : this.nickName;
    } else if (type === 'intro') {
      this.sheetTitle = "修改个人简介";
      this.inputValue = (this.intro === '暂无简介' || this.intro === '加载中...') ? '' : this.intro;
    }
  }

  // 弹窗内容构建器
  @Builder
  EditSheetBuilder() {
    Column() {
      // 顶部栏：标题 + 取消
      Row() {
        Text(this.sheetTitle).fontSize(18).fontWeight(FontWeight.Bold)
        Text("取消").fontSize(16).fontColor('#999')
          .onClick(() => { this.isShowSheet = false })
      }
      .width("100%").justifyContent(FlexAlign.SpaceBetween).padding({ bottom: 20 })

      // 输入区域
      if (this.editType === 'nickname') {
        TextInput({ text: this.inputValue, placeholder: '请输入新昵称' })
          .height(50).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange((val) => { this.inputValue = val })
      } else {
        TextArea({ text: this.inputValue, placeholder: '请输入个人简介' })
          .height(120).backgroundColor('#F5F5F5').borderRadius(8)
          .onChange((val) => { this.inputValue = val })
      }

      // 保存按钮
      Button("保存").width("100%").height(45).margin({ top: 30 })
        .backgroundColor('#0C34BA')
        .onClick(() => { this.saveInfo() })
    }
    .width('100%').height('100%').padding(20).backgroundColor(Color.White)
  }

  build() {
    Column() {
      // 1. 顶部标题栏
      Row() {
        Row() { Text("< 返回").fontColor('#0C34BA').fontSize(16) }
        .height('100%').onClick(() => { router.back() }).padding({ left: 15 })

        Text("个人资料").fontSize(18).fontWeight(FontWeight.Bold)
          .layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }
      .width("100%").height(56).backgroundColor(Color.White).zIndex(2)

      Stack({ alignContent: Alignment.Top }) {
        // 蓝色背景
        Column().width('100%').height(130).backgroundColor('#0C34BA')

        // 白色卡片
        Column() {
          Column() {
            // --- 头像 ---
            Row() {
              Text("头像").fontSize(15).fontColor('#333')
              Image($r('app.media.luckin'))
                .width(50).height(50).borderRadius(25)
                .objectFit(ImageFit.Cover).backgroundColor('#eee')
            }
            .width('100%').justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 10, bottom: 10 })

            Divider().color('#F5F5F5').strokeWidth(1)

            // --- ID ---
            Row() {
              Text("用户ID").fontSize(15).fontColor('#333')
              Text(this.userId).fontSize(14).fontColor('#999')
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 20, bottom: 20 })

            Divider().color('#F5F5F5').strokeWidth(1)

            // --- 手机号 ---
            Row() {
              Text("手机号").fontSize(15).fontColor('#333')
              Text(this.phone).fontSize(14).fontColor('#999')
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ top: 20, bottom: 20 })

            Divider().color('#F5F5F5').strokeWidth(1)

            // --- 昵称 (可点) ---
            Row() {
              Text("昵称").fontSize(15).fontColor('#333')
              Row() {
                Text(this.nickName).fontSize(14).fontColor('#666')
                Text(" >").fontSize(14).fontColor('#ccc')
              }
            }
            .width('100%').justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 20, bottom: 20 })
            .onClick(() => { this.openEditSheet('nickname') })

            Divider().color('#F5F5F5').strokeWidth(1)

            // --- 简介 (可点) ---
            Column({ space: 10 }) {
              Row() {
                Text("简介").fontSize(15).fontColor('#333')
                Text(" >").fontSize(14).fontColor('#ccc')
              }.width('100%').justifyContent(FlexAlign.SpaceBetween)

              Text(this.intro)
                .fontSize(14).fontColor('#999')
                .width('100%').lineHeight(20)
            }
            .width('100%').padding({ top: 20, bottom: 20 })
            .onClick(() => { this.openEditSheet('intro') })
          }
          .width('100%')
        }
        .width('95%').backgroundColor(Color.White).borderRadius(12)
        .padding({ left: 15, right: 15, top: 5, bottom: 20 })
        .margin({ top: 90, bottom: 20 })
      }
      .layoutWeight(1).backgroundColor('#F5F5F5')
    }
    .width('100%').height('100%')
    // 绑定半模态
    .bindSheet($$this.isShowSheet, this.EditSheetBuilder(), {
      height: 280, // 稍微高一点，防止输入框被遮挡
      dragBar: true,
      backgroundColor: Color.White,
      showClose: false
    })
  }
}
