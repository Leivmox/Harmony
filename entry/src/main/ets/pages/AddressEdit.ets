import { promptAction, router } from '@kit.ArkUI';
import { deleteAddress, editAddress, findAddressByAid } from '../api/api';

@Entry
@Component
struct AddressEdit {
  @StorageProp('token') token: string = '';
  @State name: string = '';
  @State phone: string = '';
  @State detail: string = '';
  @State postalCode: string = '';
  @State isDefault: boolean = false;
  @State regionText: string = '';
  @State aid: string = '';
  private province: string = '';
  private city: string = '';
  private county: string = '';
  private areaCode: string = '000000';

  aboutToAppear() {
    const params = router.getParams() as Record<string, string>;
    if (params && params['aid']) {
      this.aid = params['aid'];
      this.loadAddressDetail();
    } else {
      promptAction.showToast({ message: '参数错误' });
      router.back();
    }
  }

  async loadAddressDetail() {
    try {
      console.info('正在请求详情 aid:', this.aid);

      let res = await findAddressByAid(this.aid, this.token);

      let resData: Record<string, Object>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as Record<string, Object>;
      } else {
        resData = res.result as Record<string, Object>;
      }

      console.info('接口返回详情:', JSON.stringify(resData));

      if (resData.code == 200 || resData.code == 20000 || resData.code == 40000) {
        let resultData = resData.result;
        let info: Record<string, Object> = {};

        if (Array.isArray(resultData) && resultData.length > 0) {
          info = resultData[0] as Record<string, Object>;
        } else if (resultData && !Array.isArray(resultData)) {
          info = resultData as Record<string, Object>;
        }

        this.name = (info['name'] as string) || '';
        this.phone = (info['tel'] as string) || '';
        this.province = (info['province'] as string) || '';
        this.city = (info['city'] as string) || '';
        this.county = (info['county'] as string) || '';
        this.detail = (info['addressDetail'] as string) || '';
        this.postalCode = (info['postalCode'] as string) || '';

        let isDefaultVal = info['isDefault'];
        this.isDefault = (Number(isDefaultVal) === 1);

        if (this.province && this.city && this.county) {
          this.regionText = `${this.province} ${this.city} ${this.county}`;
        } else {
          this.regionText = '';
        }

        console.info('赋值完成:', `姓名:${this.name}, 电话:${this.phone}, 地区:${this.regionText}`);

      } else {
        promptAction.showToast({ message: resData.msg as string || '获取详情失败' });
      }
    } catch (err) {
      console.error('详情加载异常:', JSON.stringify(err));
      promptAction.showToast({ message: '系统异常' });
    }
  }

  async handleSave() {
    if (!this.name || !this.phone || !this.regionText || !this.detail) {
      promptAction.showToast({ message: '请完善信息' });
      return;
    }
    const params: Record<string, Object> = {
      "tokenString": this.token,
      "aid": this.aid,
      "name": this.name,
      "tel": this.phone,
      "province": this.province,
      "city": this.city,
      "county": this.county,
      "addressDetail": this.detail,
      "areaCode": this.areaCode,
      "postalCode": this.postalCode,
      "isDefault": this.isDefault ? 1 : 0
    };

    try {
      let res = await editAddress(params);
      let resData: Record<string, Object>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as Record<string, Object>;
      } else {
        resData = res.result as Record<string, Object>;
      }

      console.info('保存接口返回:', JSON.stringify(resData));

      let code = Number(resData['code']);

      if (code === 200 || code === 20000 || code === 30000 || code === 40000) {
        promptAction.showToast({ message: '修改成功' });
        setTimeout(() => router.back(), 500);
      } else {
        promptAction.showToast({ message: resData['msg'] as string || '修改失败' });
      }
    } catch (err) {
      promptAction.showToast({ message: '网络请求错误' });
    }
  }


  async handleDelete() {
    AlertDialog.show({
      title: '提示',
      message: '确定要删除这条地址吗？',
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          try {
            let res = await deleteAddress(this.aid, this.token);
            let resData: Record<string, Object>;
            if (typeof res.result === 'string') {
              resData = JSON.parse(res.result) as Record<string, Object>;
            } else {
              resData = res.result as Record<string, Object>;
            }

            console.info('删除接口返回:', JSON.stringify(resData));

            let code = Number(resData['code']);

            if (code === 200 || code === 20000 || code === 10000 || code === 40000) {
              promptAction.showToast({ message: '删除成功' });
              setTimeout(() => router.back(), 500);
            } else {
              promptAction.showToast({ message: resData['msg'] as string || '删除失败' });
            }
          } catch (err) {
            promptAction.showToast({ message: '删除出错' });
          }
        }
      }
    })
  }

  selectRegion() {
    TextPickerDialog.show({
      range: ['北京市 北京市 东城区', '广东省 广州市 天河区', '上海市 上海市 浦东新区'],
      onAccept: (value: TextPickerResult) => {
        this.regionText = value.value as string;
        let parts = this.regionText.split(' ');
        if (parts.length >= 3) {
          this.province = parts[0];
          this.city = parts[1];
          this.county = parts[2];
        }
      }
    })
  }

  @Builder
  InputRow(title: string, val: string, onChange: (v: string) => void) {
    Row() {
      Text(title).width(80).fontSize(16).fontColor('#333')
      TextInput({ text: val })
        .layoutWeight(1).backgroundColor(Color.Transparent)
        .onChange(onChange)
    }
    .height(55).width('100%').alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 0.5 }, color: '#EEE' })
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text("< 返回").fontColor('#0C34BA').fontSize(16)
        }
        .height('100%').onClick(() => router.back()).padding({ left: 15, right: 15 })

        Text("编辑地址")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ right: 60 })
      }
      .width("100%").height(56).backgroundColor(Color.White)

      Column() {

        Row() {
          Text('姓名').width(80).fontSize(16).fontColor('#333')
          TextInput({ text: this.name })
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((v) => this.name = v)
        }
        .height(55).width('100%').alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#EEE' })

        Row() {
          Text('电话').width(80).fontSize(16).fontColor('#333')
          TextInput({ text: this.phone })
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((v) => this.phone = v)
        }
        .height(55).width('100%').alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#EEE' })

        Row() {
          Text('地区').width(80).fontSize(16).fontColor('#333')
          Text(this.regionText || '请选择').layoutWeight(1).fontColor('#333')
          Text('>').fontColor('#999')
        }
        .height(55)
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#EEE' })
        .onClick(() => this.selectRegion())

        Row() {
          Text('详细地址').width(80).fontSize(16).fontColor('#333')
          TextInput({ text: this.detail })
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((v) => this.detail = v)
        }
        .height(55).width('100%').alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#EEE' })

        Row() {
          Text('邮政编码').width(80).fontSize(16).fontColor('#333')
          TextInput({ text: this.postalCode })
            .layoutWeight(1).backgroundColor(Color.Transparent)
            .onChange((v) => this.postalCode = v)
        }
        .height(55).width('100%').alignItems(VerticalAlign.Center)
        .border({ width: { bottom: 0.5 }, color: '#EEE' })

      }
      .backgroundColor(Color.White).borderRadius(8)
      .margin(15).padding({ left: 15, right: 15 })

       Row() {
        Text('设为默认收货地址').fontSize(16).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.isDefault })
          .selectedColor('#0C34BA')
          .onChange((isOn) => this.isDefault = isOn)
      }
      .height(55).backgroundColor(Color.White).borderRadius(8)
      .margin({ left: 15, right: 15, top: 15 }).padding({ left: 15, right: 15 })

      Column({ space: 15 }) {
        Button('保存', { type: ButtonType.Capsule })
          .backgroundColor('#0C34BA')
          .width('100%').height(45)
          .onClick(() => this.handleSave())

        Button('删除', { type: ButtonType.Capsule })
          .backgroundColor(Color.White)
          .fontColor(Color.Red)
          .border({ width: 1, color: '#EEE' })
          .width('100%')
          .height(45)
          .onClick(() => this.handleDelete())
      }
      .margin({ top: 40, left: 15, right: 15 })

    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}