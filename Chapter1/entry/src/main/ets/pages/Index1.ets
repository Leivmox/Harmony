class BannerClass {
  id: string = '';
  imageSrc: ResourceStr = '';
  url: string = '';

  constructor(id: string, imageSrc: ResourceStr, url: string) {
    this.id = id;
    this.imageSrc = imageSrc;
    this.url = url;
  }
}

@Entry
@Component
struct Index {
  @State message: string = '快速入门';

  build() {
    Column() {
      Row() {

        Text(this.message)
          .id('HelloWorld')
          .fontSize(24)
          .fontWeight(700)
          // .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ left: 16 })
          .fontFamily('HarmonyHeiTi-Bold')
          .lineHeight(33)

        // Blank()
        button1()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({ right: 16 })
      .margin({ top: 10 })

      Banner()
      // EnablementItem()

    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}

@Preview
@Component
struct Banner {
  @State bannerList: Array<BannerClass> = [
    new BannerClass('pic0', $r('app.media.banner_pic0'),
      'https://developer.huawei.com/consumer/cn/training/course/video/C101718352529709527'),
    new BannerClass('pic1', $r('app.media.banner_pic1'),
      'https://developer.huawei.com/consumer/cn/'),
    new BannerClass('pic2', $r('app.media.banner_pic2'),
      'https://developer.huawei.com/consumer/cn/deveco-studio/'),
    new BannerClass('pic3', $r('app.media.banner_pic3'),
      'https://developer.huawei.com/consumer/cn/arkts/'),
    new BannerClass('pic4', $r('app.media.banner_pic4'),
      'https://developer.huawei.com/consumer/cn/arkui/'),
    new BannerClass('pic5', $r('app.media.banner_pic5'),
      'https://developer.huawei.com/consumer/cn/hms')
  ];

  build() {
    Swiper() {
      ForEach(this.bannerList, (item: BannerClass, index: number) => {
        // Image($r('app.media.banner_pic1'))
        Image(item.imageSrc)

          .objectFit(ImageFit.Contain)
          .width('100%')
          .padding({ top: 11, left: 16, right: 16 })
          .borderRadius(16)
        //
        // Image($r('app.media.banner_pic2'))
        //   .objectFit(ImageFit.Contain)
        //   .width('100%')
        //   .padding({ top: 11, left: 16, right: 16 })
        //   .borderRadius(16)
      }, (item: BannerClass, index: number) => item.id)
    }
    .autoPlay(true)
    .loop(true)
    .indicator(
      new DotIndicator()
        .color('#1a000000')
        .selectedColor('#0A59F7'))
  }
}

@Preview
@Component
struct EnablementItem {
  private title: string = 'HarmonyOS第一课';
  private brief: string = '基于真实的开发场景，提供向导式学习，多维度融合课程等内容，给开发者提供全新的学习体验。';

  build() {
    Column() {
      Image($r('app.media.enablement_pic1'))
        .width('100%')
        .objectFit(ImageFit.Cover)
        .height(96)
        .borderRadius({
          topLeft: 16,
          topRight: 16
        })
      Text(this.title)
        .height(19)
        .width('100%')
        .fontSize(14)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .fontWeight(400)
        .padding({ left: 12, right: 12 })
        .margin({ top: 8 })
      Text(this.brief)
        .height(32)
        .width('100%')
        .fontSize(12)
        .textAlign(TextAlign.Start)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(2)
        .fontWeight(400)
        .fontColor('rgba(0, 0, 0, 0.6)')
        .padding({ left: 12, right: 12 })
        .margin({ top: 2 })
    }
    .width(160)
    .height(169)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}


@Preview
@Component
struct button1 {
  build() {
    Button() {
      Text('LoginPage')
        .fontSize(10)
        .fontWeight(FontWeight.Bold)
    }
    .onClick(() => {
      // this.message = 'Welcome';
      console.info(`Succeeded in clicking the 'Back' button.`)
      // 获取UIContext
      let uiContext: UIContext = this.getUIContext();
      let router = uiContext.getRouter();
      // 跳转到LoginPage
      router.pushUrl({ url: 'pages/LoginPage' }).then(() => {
        console.info('Succeeded in jumping to the Index page.')

      }).catch((err: BusinessError) => {
        console.error(`Failed to jump to the second page. Code is ${err.code}, message is ${err.message}`)
      })
    })
    // .type(ButtonType.Capsule)
    .borderRadius(5)
    // .margin({
    //   top: 20
    // })
    .backgroundColor('#FFFFFF')
    .width('20%')
    .height('2%')

  }
}