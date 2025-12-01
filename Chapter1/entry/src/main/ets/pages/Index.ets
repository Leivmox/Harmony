import { tabBarDataItemType } from '../model/model';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  //底部 tabBar 所需的数据
  //   interface tabBarDataItemType{
  //     title: string,
  //   img:Resource,
  //   img_active:Resource
  // }
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

    Tabs({ index: $$this.currentIndex }) {
      //ForEach(数组,回调函数)列表渲染,根据数组长度渲染
      ForEach(this.tabBarData, (item: tabBarDataItemType,index:number) => {
        TabContent() {
          //页面内容

          // Text(item.title)
        }.tabBar({
          //如果当前选中的标签页的索引 等于 按钮的索引，按钮的图标高亮
          icon: this.currentIndex == index ? item.img_active : item.img,
          text: item.title
        })
      })


    }.barPosition(BarPosition.End)
    .onChange((idx: number) => {
      //把激活的下标，赋值给当前显示的下标(或双向绑定)
      console.log("当前激活的下标是 =>", idx);
      console.log("当前显示的下标是 =>", this.currentIndex);
    })

    // Tabs() {
    //   TabContent() {
    //     Text("首页")
    //   }.tabBar({
    //     icon: $r("app.media.startIcon"),
    //     text: "首页"
    //   })
    //
    // TabContent() {
    //   Text("菜单")
    // }.tabBar({
    //   icon: $r("app.media.startIcon"),
    //   text: "菜单"
    // })
    //
    // TabContent() {
    //   Text("购物袋")
    // }.tabBar({
    //   icon: $r("app.media.startIcon"),
    //   text: "购物袋"
    // })
    //
    // TabContent() {
    //   Text("我的")
    // }.tabBar({
    //   icon: $r("app.media.startIcon"),
    //   text: "我的"
    // })

  }
}