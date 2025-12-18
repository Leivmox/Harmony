import { router, promptAction } from '@kit.ArkUI';
import { getStorage } from '../utils/storage';
import { findAccountInfo, ApiResponse, UserInfo } from '../api/api';

/**
 * "我的"页面
 *
 * @author Leivmox
 */
@Component
export default struct My {
  @StorageProp('token') token: string = '';

  @State nickName: string = '点击登录';
  @State desc: string = '登录后享受更多权益';
  @State menuList: string[] = [
    "个人资料",
    "我的订单",
    "我的收藏",
    "地址管理",
    "安全中心"
  ]

  private lastRefreshTime: number = 0;

  async initData() {
    let now = new Date().getTime();
    if (now - this.lastRefreshTime < 2000) {
      console.log('[MyPage] 刷新太频繁，已拦截');
      return;
    }
    this.lastRefreshTime = now;
    console.info('[MyPage] === 触发数据刷新 ===');
    let finalToken = this.token;
    let context = getContext(this);

    if (!finalToken) {
      try {
        let diskToken = await getStorage("user_token", context);
        if (diskToken) {
          finalToken = diskToken.toString();
          AppStorage.setOrCreate('token', finalToken);
        }
      } catch (e) {
        console.error('[MyPage] 读取缓存Token失败');
      }
    }
    await this.checkLoginAndGetInfo(finalToken);
  }
  async checkLoginAndGetInfo(useToken?: string) {
    let finalToken = useToken || this.token;
    if (!finalToken) {
      this.nickName = '点击登录';
      this.desc = '登录后享受更多权益';
      return;
    }

    try {
      let res = await findAccountInfo(finalToken);

      let resData: ApiResponse<UserInfo[] | UserInfo>;
      if (typeof res.result === 'string') {
        resData = JSON.parse(res.result) as ApiResponse<UserInfo[] | UserInfo>;
      } else {
        resData = res.result as ApiResponse<UserInfo[] | UserInfo>;
      }
      const codeStr = String(resData.code);
      if (['200', 'B001', 'A001', '0', '1'].includes(codeStr)) {
        let user: UserInfo | null = null;
        if (Array.isArray(resData.result)) {
          if (resData.result.length > 0) user = resData.result[0];
        } else {
          user = resData.result as UserInfo;
        }

        if (user) {
          this.nickName = user.nickName || '咖啡挚友';
          this.desc = user.desc || '暂无简介';
        }
      } else {
        if (codeStr === 'A002' || codeStr === '401') {
          this.nickName = '登录已过期';
          this.desc = '请重新登录';
        }
      }
    } catch (err) {
      console.error('[MyPage] 接口请求异常:', JSON.stringify(err));
    }
  }

  aboutToAppear() {
    this.initData();
  }

  onPageShow() {
    console.log('[MyPage] onPageShow 触发');
    this.initData();
  }

  @Builder
  SettingCell(title: string, showBorder: boolean) {
    Row() {
      Text(title).fontSize(16).fontColor('#333333')
      Blank()
      Text('>').fontSize(18).fontColor('#999999')
    }
    .width('100%')
    .height(55)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (!this.token && title !== '安全中心') {
        promptAction.showToast({ message: '请先登录' });
        router.pushUrl({ url: "pages/LoginPage" });
        return;
      }
      if (title === "我的收藏") router.pushUrl({ url: "pages/MyCollect" });
      else if (title === "个人资料") router.pushUrl({ url: "pages/PersonalInfo" });
      else if (title === "我的订单") router.pushUrl({ url: "pages/MyOrders" });
      else if (title === "安全中心") router.pushUrl({ url: "pages/SafetyCenter" });
      else if (title === "地址管理") router.pushUrl({ url: "pages/AddressManage" });
    })
    .backgroundColor(Color.Transparent)

    if (showBorder) {
      Divider().color('#F0F0F0').strokeWidth(1)
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Top }) {
        Image($r('app.media.luckin_bg'))
          .width('100%')
          .height(235)
          .objectFit(ImageFit.Cover)

        Column() {
          Row() {
            Image($r('app.media.luckin'))
              .width(70)
              .height(70)
              .borderRadius(35)
              .objectFit(ImageFit.Cover)
              .margin({ right: 15 })
              .backgroundColor(Color.White)

            Column({ space: 8 }) {
              Text(this.nickName)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#3D59AB')

              Text(this.desc)
                .fontSize(13)
                .fontColor('#666666')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 20, bottom: 30, left: 10, right: 10 })
          .onClick(() => {
            if (!this.token) {
              router.pushUrl({ url: "pages/LoginPage" })
            } else {
              router.pushUrl({ url: "pages/PersonalInfo" })
            }
          })

          Column() {
            ForEach(this.menuList, (item: string, index: number) => {
              this.SettingCell(item, index !== this.menuList.length - 1)
            })
          }
        }
        .width('95%')
        .backgroundColor('rgba(255, 255, 255, 0.8)')
        .backdropBlur(10)
        .borderRadius(12)
        .shadow({ radius: 10, color: '#1A000000', offsetY: 5 })
        .padding({ left: 15, right: 15, bottom: 10 })
        .margin({ top: 190 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')

    .onVisibleAreaChange([0.0, 0.5, 1.0], (isVisible: boolean, currentRatio: number) => {
      console.log(`[MyPage] 可见性变化: isVisible=${isVisible}, ratio=${currentRatio}`);

      if (isVisible && currentRatio > 0.5) {
        this.initData();
      }
    })
  }
}
