import { promptAction, router } from '@kit.ArkUI';
import { addAddress, AddressParams } from '../api/api'; // 确保路径正确
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct AddressAdd {
  // --- 状态变量 ---
  @StorageProp('token') token: string = ''; // 获取全局Token
  @State name: string = '';
  @State phone: string = '';
  @State detail: string = '';
  @State postalCode: string = '';
  @State isDefault: boolean = false;
  // 地区相关变量
  @State regionText: string = ''; // 用于显示： "广东省 广州市 天河区"
  // 提交给后端的字段
  private province: string = '';
  private city: string = '';
  private county: string = '';
  private areaCode: string = '000000'; // 默认或根据选择器获取

  // --- 逻辑方法 ---

  // 1. 选择地区 (模拟)
  selectRegion() {
    TextPickerDialog.show({
      range: ['北京市 北京市 东城区', '上海市 上海市 黄浦区', '广东省 广州市 天河区', '浙江省 杭州市 西湖区'],
      onAccept: (value: TextPickerResult) => {
        // 拿到选择的字符串
        this.regionText = value.value as string;

        // 简单拆分数据用于接口提交 (实际项目中应使用三级联动选择器获取对象)
        let parts = this.regionText.split(' ');
        if (parts.length >= 3) {
          this.province = parts[0];
          this.city = parts[1];
          this.county = parts[2];
        }
      }
    })
  }

  // 2. 保存地址
   async handleSave() {
    // 1. 检查 Token
    if (!this.token) {
      promptAction.showToast({ message: '未登录或Token失效' });
      return;
    }

    // 2. 简单校验
    if (!this.name || !this.phone || !this.regionText || !this.detail) {
      promptAction.showToast({ message: '请填写完整信息' });
      return;
    }
    if (this.phone.length !== 11) {
      promptAction.showToast({ message: '手机号格式不正确' });
      return;
    }

    // 3. 构造参数
    const params: AddressParams = {
      tokenString: this.token,
      name: this.name,
      tel: this.phone,
      province: this.province,
      city: this.city,
      county: this.county,
      addressDetail: this.detail,
      areaCode: this.areaCode,
      postalCode: this.postalCode,
      isDefault: this.isDefault ? 1 : 0
    };

    try {
      // 4. 发起请求
      let res = await addAddress(params);

      let resData: Record<string, Object>;
      // 解析结果
      if (typeof res.result === 'string') {
        try {
          resData = JSON.parse(res.result) as Record<string, Object>;
        } catch (e) {
          promptAction.showToast({ message: '服务器错误' });
          return;
        }
      } else {
        resData = res.result as Record<string, Object>;
      }

      console.info('新增提交结果:', JSON.stringify(resData));

      // 5. 判断业务状态码
      let code = Number(resData['code']);

      if (code === 200 || code === 20000 || code === 10000 || code === 30000 || code === 9000) {
        promptAction.showToast({ message: '地址添加成功' });

        // 延迟 800ms 后自动返回上一页
        setTimeout(() => {
          router.back();
        }, 800);

      } else {
        // 失败时显示具体信息
        promptAction.showToast({ message: resData['msg'] as string || `添加失败(${code})` });
      }
    } catch (err) {
      console.error('网络请求异常:', JSON.stringify(err));
      promptAction.showToast({ message: '网络请求错误' });
    }
  }

  // --- UI 构建 ---
  // 通用输入行样式封装
  @Builder
  InputRow(title: string, placeholder: string, text: string, onChange: (val: string) => void) {
    Row() {
      Text(title)
        .width(80)
        .fontSize(16)
        .fontColor('#333')

      TextInput({ placeholder: placeholder, text: text })
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .fontSize(16)
        .placeholderColor('#ccc')
        .onChange((value: string) => {
          onChange(value)
        })
    }
    .height(55)
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 0.5 }, color: '#EEE' }) // 底部细分割线
  }

  build() {
    Column() {
      // 1. 顶部导航
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
        .padding({ left: 15, right: 15 })

        Text("新增地址")
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

      // 2. 表单内容区域
      Column() {
        // 姓名
        this.InputRow('姓名', '请输入姓名', this.name, (val) => this.name = val)

        // 电话
        this.InputRow('电话', '请输入手机号', this.phone, (val) => this.phone = val)

        // 地区选择
        Row() {
          Text('地区')
            .width(80)
            .fontSize(16)
            .fontColor('#333')

          Text(this.regionText || '请选择省市区')
            .fontSize(16)
            .fontColor(this.regionText ? '#333' : '#ccc')
            .layoutWeight(1)

          Text('>')
            .fontSize(18)
            .fontColor('#999')
            .margin({ right: 5 })
        }
        .height(55)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#EEE' })
        .onClick(() => {
          this.selectRegion()
        })

        // 详细地址
        this.InputRow('详细地址', '街道门牌、楼层房间号等信息', this.detail, (val) => this.detail = val)

        // 邮政编码
        Row() {
          Text('邮政编码')
            .width(80)
            .fontSize(16)
            .fontColor('#333')

          TextInput({ placeholder: '邮政编码', text: this.postalCode })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .fontSize(16)
            .placeholderColor('#ccc')
            .onChange((value: string) => {
              this.postalCode = value
            })
        }
        .height(55)
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin(15)
      .padding({ left: 15, right: 15 })

      // 3. 设为默认地址开关
      Row() {
        Text('设为默认收货地址')
          .fontSize(16)
          .fontColor('#333')
          .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
          .selectedColor('#0C34BA')
          .onChange((isOn: boolean) => {
            this.isDefault = isOn
          })
      }
      .height(55)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .margin({ left: 15, right: 15 })
      .padding({ left: 15, right: 15 })

      // 4. 保存按钮
      Button('保存', { type: ButtonType.Capsule })
        .backgroundColor('#0C34BA')
        .width('90%')
        .height(45)
        .margin({ top: 40 })
        .onClick(() => {
          this.handleSave()
        })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
