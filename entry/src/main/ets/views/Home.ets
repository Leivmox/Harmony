//导入数据接口
import { banner, homeProductList } from "../api/api"

//导入类型约束
import {
  bannerResultType, bannerItemType, productListType, productItem
} from "../model/model"
import { getStorage } from "../utils/storage";
import { router } from "@kit.ArkUI";


//自定义组件 -- 首页
@Component
export default struct Home {
  //轮播图列表数据
  @State bannerList: bannerItemType[] = [];
  //首页商品列表
  @State productList: productItem[] = [];

  //生命周期:可以操作数据，是在页面显示之前执行的方法
  aboutToAppear() {
    //调用方法，获取banner数据
    this.getBannerData();
    //调用方法，获取商品列表
    this.getProductList();

    let str = getStorage("test")
    console.log("当前页面，获取到持久化数据 =>",str)
  }



  //自定义方法 -- 获取首页商品列表
  private getProductList() {
    //调用接口 获取商品列表
    homeProductList()
      .then((res) => {
        //获取商品列表
        let productList: productItem[] = Object(res).result.result;
        //把商品列表赋值给状态变量
        this.productList = productList;
        console.log("首页商品列表 =>", JSON.stringify(this.productList))
      })
  }

  //自定义方法 -- 获取轮播图数据
  private getBannerData() {
    //调用接口 获取数据
    banner()
      .then((res) => {

        //拿到轮播图数组
        let arr: bannerItemType[] = Object(res).result.result;
        //操作数据（避免操作状态变量）

        //赋值给状态变量，由状态变量去更新页面
        this.bannerList = arr;
        console.log("轮播图数据 =>", JSON.stringify(this.bannerList))
      })
  }

  //页面结构
  build() {
    //根节点
    Column() {
      //1.顶部导航
      Row({ space: 40 }) {
        //a.左边文本
        Row({ space: 10 }) {
          Text("下午好")
            .fontSize(14)
          Text("登录")
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
        }

        //b.右边搜索框
        Search({ placeholder: "请输入搜索关键字" })
          .layoutWeight(1)
          .placeholderFont({
            size: 14,
            weight: FontWeight.Normal,
            style: FontStyle.Normal
          })
      }
      .width("100%")
      .padding({ left: 20, right: 20 })
      .backgroundColor(Color.White)

      //2.滚动视图容器(高度跟随父组件，这里要减去顶部导航的高度56vp)
      Scroll() {
        //单一子节点
        Column() {
          //需要滚动的页面内容

          //2.轮播图
          Swiper() {
            ForEach(this.bannerList, (item: bannerItemType, index: number) => {
              Image(item.bannerImg)
            })
          }.indicator(
            //修改面板指示点样式
            Indicator.dot()//返回面板指示点对象
              .selectedColor($r("app.color.theme_color"))//选中是颜色
              .color("rgba(255,255,255,.5")//未选中颜色
              .right(20) //面板指示点的位置
          )

          //3.商品列表
          Flex({
            wrap: FlexWrap.Wrap  //定义如何换行
          }) {
            //根据商品数组列表，遍历商品的每一项
            ForEach(this.productList, (item: productItem, index: number) => {
              // 每一个商品
              Column() {
                Image(item.smallImg)
                  .width("100%")
                  .height(165)
                  .margin({ bottom: 10 })
                Text(item.name)
                  .fontSize(18)
                Text(item.enname)
                  .fontColor($r("app.color.unselected_text_color"))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text("￥" + item.price)
              }
              .width("calc(50% - 5vp )")
              .margin({
                right: index % 2 == 0 ? 10 : 0,
                bottom: 10
              })
              .padding({ bottom: 10 })
              .alignItems(HorizontalAlign.Start)
              .backgroundColor(Color.White)
              .onClick(()=>{
                router.pushUrl({
                  url:"pages/DetailPage",
                  params:{
                    pid: item.pid
                  }
                })
              })
            })
          }
          .padding(10)
        }
      }
      .height("calc(100% - 56vp)")
      .scrollBar(BarState.Off) //scroll容器 关闭滚动条
    }
    .height(("100%"))
    .backgroundColor("#efefef")
  }
}
