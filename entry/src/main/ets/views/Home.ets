//自定义组件 -- 首页
@Component
export default struct Home {
  build() {
    //根节点
    Column(){
      //1.顶部导航
      Row(){
        //a.左边文本
        Text("晚上好")
        Text("登录")
          .fontWeight(FontWeight.Bold)

        //b.右边搜索框
      }
      .width("100%")
      .background(Color.Pink)
      .padding({
        left:20,
        right:20
      })
    }
  }
}
