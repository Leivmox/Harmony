import { router, promptAction } from '@kit.ArkUI';
import { findAddress } from '../api/api';
import { BusinessError } from '@kit.BasicServicesKit';
import { getStorage } from '../utils/storage'; // 1. 导入读取工具

interface AddressItem {
  id: number | string;
  name: string;
  phone: string;
  address: string;
  isDefault: boolean;
}

@Entry
@Component
struct AddressManage {
  @StorageProp('token') token: string = '';
  @State addressList: AddressItem[] = [];
  @State isLoading: boolean = false;

  // 从硬盘获取Token
  async aboutToAppear() {
    // 1. 如果内存里已经有token（比如是从登录页刚跳过来的），直接请求数据
    if (this.token) {
      console.info('【Token状态】内存中存在，直接请求');
      this.getAddressList();
    } else {
      // 2. 如果内存里没有，尝试去硬盘获取
      console.info('【Token状态】内存为空，尝试读取硬盘...');
      let context = getContext(this);

      let diskToken = await getStorage("user_token", context);

      if (diskToken) {
        console.info('【Token状态】硬盘中找到了！复活Token');

        AppStorage.setOrCreate('token', diskToken as string);

        this.getAddressList(diskToken as string);
      } else {
        console.warn('【Token状态】硬盘里也没有，确实未登录');
        promptAction.showToast({ message: '请先登录' });


      }
    }
  }

  // 页面显示时触发 (比如从编辑页回来)
  onPageShow() {
    // 如果已经有数据，且 token 存在，可以在这里刷新
    if (this.token) {
      this.getAddressList();
    }
  }


  async getAddressList(useToken?: string) {
    // 优先使用传入的 token，如果没有则使用 this.token
    let finalToken = useToken || this.token;

    if (!finalToken) {
      console.warn('Token为空，无法请求');
      return;
    }

    this.isLoading = true;

    try {
      let res = await findAddress(finalToken);

      let resData: Record<string, Object>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as Record<string, Object>;
      } else {
        resData = res.result as Record<string, Object>;
      }

      console.info('【调试】服务器状态码:', resData.code);

      if (resData.code == 200 || resData.code == '200' || resData.code == 20000) {

        let originList: Array<Record<string, Object>> = [];

        if (Array.isArray(resData.result)) {
          originList = resData.result as Array<Record<string, Object>>;
        } else if (Array.isArray(resData.data)) {
          originList = resData.data as Array<Record<string, Object>>;
        }

        this.addressList = originList.map((item: Record<string, Object>) => {
          return {
            id: item.aid as string,
            name: item.name as string,
            phone: item.tel as string,
            address: `${item.province || ''}${item.city || ''}${item.county || ''} ${item.addressDetail || ''}`,
            isDefault: item.isDefault === 1 || item.isDefault === true
          } as AddressItem;
        });

      } else {
        promptAction.showToast({ message: resData.msg as string || '获取失败' });
        //登出逻辑
      }

    } catch (err) {
      let error = err as BusinessError;
      console.error('【网络异常】:', JSON.stringify(error));
      promptAction.showToast({ message: '网络请求错误' });
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  AddressCard(item: AddressItem) {
    Row() {
      Column({ space: 8 }) {
        Row({ space: 10 }) {
          Text(item.name).fontSize(16).fontColor('#333').fontWeight(FontWeight.Bold)
          Text(item.phone).fontSize(14).fontColor('#666')
          if (item.isDefault) {
            Text("默认")
              .fontSize(10).fontColor(Color.White).backgroundColor('#0C34BA')
              .padding({ left: 4, right: 4, top: 2, bottom: 2 }).borderRadius(4)
          }
        }.width('100%').alignItems(VerticalAlign.Center)

        Text(item.address)
          .fontSize(14).fontColor('#333').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)

      Image($r('app.media.Edit'))
        .width(25).height(25).objectFit(ImageFit.Contain).fillColor('#999').margin({ left: 16 }).padding(4)
        .onClick(() => {
          router.pushUrl({
            url: "pages/AddressEdit",
            params: {
              aid: item.id + ''
            }
          })
        })
    }
    .width('100%').padding(15).backgroundColor(Color.White).borderRadius(8).margin({ bottom: 10 })
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Row() { Text("< 返回").fontColor('#0C34BA').fontSize(16) }
        .height('100%').onClick(() => router.back()).padding({ left: 15, right: 15 })
        Text("地址管理").fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).padding({ right: 60 })
      }.width("100%").height(56).backgroundColor(Color.White)

      // 列表区域
      if (this.isLoading && this.addressList.length === 0) {
        Column() { Text('加载中...').fontColor('#999').margin({top: 50}) }.width('100%').layoutWeight(1)
      } else if (this.addressList.length === 0) {
        Column() { Text('暂无收货地址').fontColor('#999').fontSize(16).margin({top: 100}) }.width('100%').layoutWeight(1)
      } else {
        List() {
          ForEach(this.addressList, (item: AddressItem) => {
            ListItem() { this.AddressCard(item) }
          })
        }
        .width('100%').layoutWeight(1).padding({ left: 15, right: 15, top: 15 })
      }

      // 底部按钮
      Column() {
        Button("新增地址")
          .width('100%').height(50).backgroundColor('#0C34BA').borderRadius(25)
          .onClick(() => { router.pushUrl({ url: "pages/AddressAdd" }) })
      }.width('100%').padding(20).backgroundColor('#F5F5F5')
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }
}
