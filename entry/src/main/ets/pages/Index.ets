//导入类型约束
import { tabBarDataItemType } from "../model/model"

//导入自定义组件
import Home from "../views/Home"
import MenuPage from "../views/Menu"
import ShopBag from "../views/ShopBag"
import My from "../views/My"


@Entry
@Component
struct Index {
  //默认选中第几个标签页
  @State currentIndex: number = 1;


  //底部 tabBar所需要的数据
  private tabBarData: tabBarDataItemType[] = [{
    title: "首页",
    img: $r("app.media.home"),
    img_active: $r("app.media.home_active")
  }, {
    title: "菜单",
    img: $r("app.media.menu"),
    img_active: $r("app.media.menu_active")
  }, {
    title: "购物袋",
    img: $r("app.media.shopbag"),
    img_active: $r("app.media.shopbag_active")
  }, {
    title: "我的",
    img: $r("app.media.my"),
    img_active: $r("app.media.my_active")
  }];

  //页面内容
  build() {
    Tabs({
      index: $$this.currentIndex,
      barPosition: BarPosition.End
    }) {
      //ForEach（数组，回调函数）列表渲染，根据数组长度渲染
      ForEach(this.tabBarData, (item: tabBarDataItemType, index: number) => {
        TabContent() {
          //标签页内容
          if (index == 0) {
            Home()
          } else if (index == 1) {
            MenuPage()
          } else if (index == 2) {
            ShopBag()
          } else {
            My()
          }
        }
        .tabBar(
          new BottomTabBarStyle(
            this.currentIndex == index ? item.img_active : item.img,
            item.title
          )
          //设置文本样式
            .labelStyle({
              selectedColor: $r("app.color.theme_color"),
              unselectedColor: $r("app.color.unselected_text_color")
            })
        )

        // .tabBar({
        //   //如果的当前选中的标签页的索引 等于 按钮的索引，按钮的图标高亮
        //   icon: this.currentIndex == index ? item.img_active: item.img,
        //   text: item.title
        // })
      })

    }
    .barPosition(BarPosition.End)

    // .onChange((idx: number) => {
    //   console.log("当前激活的下标是=>", idx)
    //   console.log("当前显示的下标=>",this.currentIndex)
    // })
  }
}