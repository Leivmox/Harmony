import { LengthMetrics, router } from '@kit.ArkUI'
import { clearStorage, getStorage, saveStorage } from '../utils/storage'
//导入接口
import { searchProduct } from '../api/api';
//导入数据类型
import { searchProductItem } from '../model/model'

@Entry
@Component
struct SearchPage {
  //要存入缓存的key
  private search_history_key = "search_history";
  //搜索历史记录列表
  @State search_history_list: string[] = [];
  //搜索商品类别
  @State search_product_list: searchProductItem[] = [];
  //是否显示历史记录列表
  @State is_show_history : boolean = true;
  //输入框的值
  @State search_input_val :string ="";

  //生命周期：此处可以操作数据，是在页面显示之前执行的方法
  aboutToAppear() {
    //获取搜索历史记录
    this.search_history_list = getStorage(this.search_history_key) as string[];
    //根据数组长度决定是否显示历史记录
    this.is_show_history = Boolean(this.search_history_list.length);
    console.log("历史记录 =>", JSON.stringify(this.search_history_list))

    //显示默认商品
    // this.getSearchProduct("糖");
  }

  //自定义函数 -- 通过关键字搜索商品的接口
  private getSearchProduct(keyword: string) {
    searchProduct(keyword).then( res => {
      //拿到结果
      let search_product_list: searchProductItem[] = Object(res).result.result;
      //赋值给状态变量
      this.search_product_list = search_product_list;
      console.log(`${keyword} =>`, JSON.stringify( this.search_history_list ))
    })
  }

  build() {
    Column() {

      //1. 顶部搜索
      Row({ space: 15 }) {
        Text("< 返回")
          .onClick(()=>{
            router.back() //返回上一个页面
          })
        // 搜索栏
        Search({ placeholder: "请输入关键字",value:$$this.search_input_val })
          .layoutWeight(1)
          .height(40)
          .backgroundColor("#ddd")
          .padding({ left: 10, right: 10 })
          .onSubmit((str: string) => {
            console.log("输入框的值 =>", str)

            //用搜索关键字 获取 商品
            this.getSearchProduct(str);

            //如果当前输入的值 在原本的记录中已经存在
            let idx = this.search_history_list.indexOf(str);
            if (idx != -1) {
              this.search_history_list.splice(idx, 1)
            }
            //把输入框的值，推入数组头部
            this.search_history_list.unshift(str)
            //显示历史记录内容
            this.is_show_history = true;
            console.log("修改后的历史记录 ", JSON.stringify(this.search_history_list))

            //搜索历史记录
            let key = this.search_history_key;
            let val: string[] = this.search_history_list; //咖啡 拿铁
            saveStorage(key, val)
          })
        Text("取消")
      }
      .backgroundColor(Color.White)
      .padding({ left: 20, right: 20 })

      //2.历史记录列表长度不为0 显示历史记录
      if (this.is_show_history) {
        Column() {
          //a. 历史记录标签
          Flex({
            wrap: FlexWrap.Wrap, //放不下换行
            space: {
              main: LengthMetrics.vp(10), //主轴间距
              cross: LengthMetrics.vp(10)//交叉轴间距
            }
          }) {
            //遍历历史记录列表，创建历史记录标签
            ForEach(this.search_history_list, (item: string, index: number) => {
              Text(`${item} x`)
                .padding(10)
                .backgroundColor(0xdddddd)
                .fontSize(14)
                .fontColor(Color.Black)
                .onClick(()=>{
                  //item 是当前点击的搜索记录文本
                  this.search_input_val = item;
                  //点击标签，搜索当前商品
                  this.getSearchProduct(item)
                  //删除当前点击的历史记录
                  this.search_history_list.splice(index,1)
                  //把当前的记录，存入到数组头部
                  this.search_history_list.unshift(item)
                  //持久化存储 搜索历史
                  saveStorage(this.search_history_key,this.search_history_list)
                })
            })
          }
          .margin({ top: 10, bottom: 10 })

          //b.清楚搜索历史的按钮
          Button('清除所有搜索历史')
            .onClick(() => {
              //清除所有历史记录
              clearStorage()
              //初始化历史记录的列表
              this.search_history_list = [];
              //不显示 历史记录 页面内容
              this.is_show_history = false;
              this.search_product_list = [];
            })
            .width("60%")
            .height(40)
            .backgroundColor("#ddd")
            .fontColor(Color.Black)
            .margin({ top: 20, bottom: 10 })
        }
        .width("100%")
        .backgroundColor(Color.White)
        .padding(10)
      }

      // 3.商品列表
      Scroll() {
        Column() {
          //3.商品列表 flex布局容器组件
          Flex({
            wrap: FlexWrap.Wrap  //定义如何换行
          }) {
            //根据商品数组列表，遍历商品的每一项
            ForEach(this.search_product_list, (item: searchProductItem, index: number) => {
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
        .height(this.search_history_list.length < 3 ? "100%" : "")
        .justifyContent(FlexAlign.Start)
      }
      .width("100%")
      .height(this.is_show_history ? "calc(100% - 222.23vp)" : "calc(calc(100% - 56vp))")
      .backgroundColor(0xefefef)

    }
    .height("100%")
    .backgroundColor("#ddd")
  }
}