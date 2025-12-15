//导入数据接口
import { menuSideBar,menuProductList } from "../api/api"

//导入类型约束
import { sideBarItem,productItem } from "../model/model"
import { router } from "@kit.ArkUI";

//自定义组件 -- 菜单
@Component
export default struct MenuPage {
  //侧边栏列表
  @State sideBarList: sideBarItem[] = [];
  //当前激活侧边栏的索引
  @State currentSideBarIndex: number = 0;
  //当前分类的商品数据
  @State productList: productItem[] = [];

  //生命周期-- 页面即将显示
  aboutToAppear() {
    //获取商品分类
    this.getMenuSideBar();
  }

  //自定义函数 -- 获取侧边栏按钮的文本
  private getMenuSideBar() {
    menuSideBar()
      .then(res => {
        //请求到侧边栏数据
        let sideBarList: sideBarItem[] = Object(res).result.result;
        this.sideBarList = sideBarList;
        console.log("获取侧边栏数据 =>", JSON.stringify(this.sideBarList))

        //等获取到商品分类，再调用 分类获取商品的方法
        this.getProductListByMenu();
      })
  }

  //获取当前分类的商品
  private getProductListByMenu(){
    //当前要获取的类型的商品
    let type = this.sideBarList[this.currentSideBarIndex].type
    //参数：商品分类
    menuProductList(type)
      .then( res=>{
        // 获取到商品数据
        let productList: productItem[] = Object(res).result.result;
        // 赋值给状态变量
        this.productList = productList;
        console.log("当前${type}类型的商品有: ${this.productList}")
      })
  }
  //页面结构
  build() {
    Column() {
      // 1.顶部导航
      Row() {
        Search({ placeholder: "请输入搜索关键字" })
          .margin({ left: 20, right: 20, bottom: 20 })
      }.backgroundColor(Color.White)

      //2.内容
      Row() {
        //a.左侧菜单栏
        Column() {
          ForEach(this.sideBarList, (item: sideBarItem, index: number) => {
            Text(item.typeDesc)
              .width("100%")
              .height(50)
              .padding({ left: 20 })
              .backgroundColor( this.currentSideBarIndex == index? Color.White : Color.Transparent)
              .border({
                width: { left: 5 },
                color: this.currentSideBarIndex == index? $r("app.color.theme_color") : Color.Transparent
              })
              .onClick( () => {
                //点击的菜单的下标，赋值给 currentSideBarIndex
                this.currentSideBarIndex = index
                //切换菜单，重新获取当前分类的商品
                this.getProductListByMenu();
              })
          })
        }
        .width("30%")
        .height("100%")

        //b.右侧商品列表
        Scroll() {
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
                  .height(110)
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
                // 页面跳转
                router.pushUrl({
                  url:"pages/DetailPage",
                  //路由参数
                  params:{
                    pid:item.pid
                  }
                })
              })
            })
          }
          .padding(10)
        }
        .width("70%")
        .backgroundColor(Color.White)
      }
      .height("calc(100% - 60vp)")
      .alignItems(VerticalAlign.Top)
    }
    .height("100%")
    .backgroundColor(0xefefef)
  }
}