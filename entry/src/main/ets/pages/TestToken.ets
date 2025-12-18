import { router, promptAction } from '@kit.ArkUI';
import { addAddress, AddressParams } from '../api/api';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct TestToken {
  @StorageProp('token') token: string = '等待获取...';

  build() {
    Column({ space: 20 }) {
      // 标题栏
      Row() {
        // 这里假设你有返回图标，如果没有可以用 Text('<') 代替
        Text('< 返回')
          .fontSize(16)
          .fontColor('#0C34BA')
          .onClick(() => router.back())
        Text('Token 测试诊断')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 10 })
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)

      // 显示当前 Token
      Column() {
        Text('当前内存中的 Token:')
          .fontSize(14)
          .fontColor('#666')

        Text(this.token)
          .fontSize(14)
          .fontColor(this.token && this.token !== '等待获取...' ? '#0C34BA' : Color.Red)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 10 })
          .padding(10)
          .backgroundColor('#EEE')
          .width('90%')
      }
      .alignItems(HorizontalAlign.Start)
      .padding(10)

      // 操作按钮区域
      Column({ space: 15 }) {

        Button('1. 去登录页面 (LoginPage)')
          .width('80%')
          .onClick(() => {
            router.pushUrl({ url: 'pages/LoginPage' });
          })

        Button('2. 测试新增地址接口')
          .width('80%')
          .backgroundColor(this.token && this.token !== '等待获取...' ? '#0C34BA' : '#ccc')
          .onClick(async () => {
            if (!this.token || this.token === '等待获取...') {
              promptAction.showToast({ message: 'Token 为空，无法测试' });
              return;
            }

            // 2. 【修复报错点 1】显式指定类型为 AddressParams
            // 确保 api.ets 中 export interface AddressParams 已定义
            const params: AddressParams = {
              tokenString: this.token,
              name: "测试员",
              tel: "13800138000",
              province: "测试省",
              city: "测试市",
              county: "测试区",
              addressDetail: "测试街道1号",
              areaCode: "000000",
              postalCode: "100000",
              isDefault: 0
            };

            try {
              promptAction.showToast({ message: '请求发送中...' });
              let res = await addAddress(params);

              // =========================
              // 【核心修复部分】开始
              // =========================
              let jsonRes: Record<string, Object>;

              // 1. 判断 res.result 的类型
              if (typeof res.result === 'string') {
                // 如果是字符串，说明需要解析
                jsonRes = JSON.parse(res.result) as Record<string, Object>;
              } else {
                // 如果已经是对象 (Object)，直接强转使用，不要 toString，也不要 parse
                jsonRes = res.result as Record<string, Object>;
              }

              // 2. 打印看一下真实数据 (用 JSON.stringify 才能看清对象内容)
              console.info('接口最终数据:', JSON.stringify(jsonRes));

              // 3. 弹窗显示
              promptAction.showDialog({
                title: '请求成功',
                message: JSON.stringify(jsonRes, null, 2)
              });
              // =========================
              // 【核心修复部分】结束
              // =========================

            } catch (err) {
              let error = err as BusinessError;
              promptAction.showDialog({
                title: '发生错误',
                // 如果出错，也要用 JSON.stringify 才能看清 error 对象的内容
                message: JSON.stringify(error)
              });
            }
          })

        Button('3. 清除 Token (模拟退出)')
          .width('80%')
          .backgroundColor('#FF4D4F')
          .onClick(() => {
            AppStorage.setOrCreate('token', '');
            promptAction.showToast({ message: 'Token 已清除' });
          })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
