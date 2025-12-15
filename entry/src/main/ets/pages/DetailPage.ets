import { productDetail,toggleLike,findLike,shopcartRows, addShopcart} from '../api/api'
import { promptAction, router } from '@kit.ArkUI';
import { productDetailType, product_rule, product_rule_item } from "../model/model"
import { getStorage } from '../utils/storage';


@Entry
@Component
struct DetailPage {
  //商品详情
  @State product_detail: productDetailType[] = [];
  //商品规格
  @State product_rule: product_rule = {};
  //商品是否有被收藏
  @State is_like:boolean = false;
  //商品数量
  @State count:string = "1";
  //购物车商品条目
  @State badge_count:number = 0;
  //商品id
  private pid: string = "";
  //用户的token
  private user_token:string = "";

  //生命周期 -- 页面即将显示
  aboutToAppear() {
    let params:object = router.getParams();
    // console.log("路由参数 =>",JSON.stringify(params))

    //通过路由参数获取商品ID
    this.pid = Object(params).pid || "fruit_tea005";

    //获取用户的token(有token就有登录，没有token就没有登录)
    this.user_token = getStorage("user_token") as string;
    console.log("用户token =>",this.user_token)

    //获取商品详情
    this.getProductDetailByPid();
    //查看当前商品是否被收藏
    this.findCurrentProductIsLike();
    //查看购物车的商品条数
    this.queryShopcartRows();
  }

  //自定义方法 -- 通过pid获取商品详情
  private getProductDetailByPid() {
    productDetail(this.pid)
      .then(res => {
        this.product_detail = Object(res).result.result;
        console.log("获取商品详情 =>", JSON.stringify(this.product_detail))

        //要配置的商品规格
        let rule_arr: string[] = ["tem", "milk", 'sugar', "cream"];
        let product_rule: product_rule = {};
        //遍历数组，在商品详情中，剔除无效的商品配置
        for (const item of rule_arr) {
          // console.log(item+ "这个配置的值 =>",this.product_detail[item])
          if (Object(this.product_detail[0])[item]) {
            //当前有效的商品规格(小对象)
            let obj: product_rule_item = { };
            obj.desc = Object((this.product_detail)[0])[item+"_desc"];
            obj.idx = 0; //默认选中的规格索引
            obj.arr = Object((this.product_detail)[0])[item].split("/"); //规格右边的按钮，是一个数组
            console.log("小规格对象 =>",JSON.stringify(obj))
            Object(product_rule)[item]= obj;
          }
        }
        //把局部变量赋值给状态变量
        this.product_rule=product_rule;
        console.log("大对象 =>",JSON.stringify(product_rule))
        //处理规格
        // 1.判断规格是否有效，不要空配置
        // 2.把非空的配置加入对象product_rule
        //3.添加描述和索引
        //4.split（"/"）把字符串切割成数组，把数组加入到对象中
      })
  }
  //自定义方法 -- 查看当前商品是否被收藏
  private findCurrentProductIsLike(){
    //只有用户登录，才可以查看当前商品是否被这个用户收藏
    if(this.user_token.length){
      findLike(this.pid,this.user_token)
        .then(res=>{
          this.is_like = Boolean(Object(res).result.result.length)
          console.log("当前的商品是否被收藏 =>",this.is_like)
        })
    }
  }
  //自定义方法 -- 查看购物车的商品条数
  private queryShopcartRows(){
    if(this.user_token.length){
      shopcartRows(this.user_token)
        .then(res=>{
          console.log("购物车的条数 =>",JSON.stringify(Object(res).result))
          this.badge_count = Object(res).result.result;
        })
    }
  }

  build() {
    Column() {
      //1.顶部导航
      Row({ space: 15 }) {
        Text("< 返回")
          .position({
            left: 0,
            top: 0
          })
          .zIndex(9)
          .height(56)
          .fontColor($r("app.color.theme_color"))
          .onClick(()=>{
            router.back()
          })

        Text("商品详情")
          .width("100%")
          .fontSize(18)
          .textAlign(TextAlign.Center)
          .zIndex(0)

      }
      .height(56)
      .backgroundColor(Color.White)
      .padding({ left: 10, right: 10 })

      Scroll() {
        // 将所有内容包裹在一个Column容器中
        Column() {
          // 第一个Column：图片、名称价格、商品规格
            // 2.图片
            Image(this.product_detail[0]?.small_img)
              .width("100%")
              .height(300)
            // 3.名称和价格
          Row() {
              // a.左边名称
              Column() {
                Text(this.product_detail[0]?.name)
                Text(this.product_detail[0]?.enname)
              }
              .alignItems(HorizontalAlign.Start)

              // b.右边价格
              Text("￥" + this.product_detail[0]?.price)
                .fontColor(Color.Red)
            }
            .width("100%")
            .padding({ left: 10, right: 10 })
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor(Color.White)

            // 4.商品规格
          Column({ space: 12 }) {
              ForEach(Object.keys(this.product_rule), (item: string) => {
                Row({ space: 30 }) {
                  Text(Object(this.product_rule)[item].desc)
                    .fontSize(16)
                    .width(40)

                  // 右边的按钮
                  Row() {
                    ForEach(Object(this.product_rule)[item].arr, (ele: string, index: number) => {
                      Button(ele)
                        .width(72)
                        .height(26)
                        .padding(0)
                        .backgroundColor(Object(this.product_rule)[item].idx == index ? $r("app.color.theme_color") :"#ddd")
                        .fontColor(Object(this.product_rule)[item].idx == index ? Color.White : "#333")
                        .fontSize(12)
                        .margin({ right: 10 })
                        .onClick(() => {
                          console.log("index =>", index)
                          Object(this.product_rule)[item].idx = index;
                          console.log("当前选中的子对象的索引 =>", Object(this.product_rule)[item].idx);

                          // 状态变量指挥处理"引用类型"的第一层的属性变化，第二层以上的属性变化不会驱动视图更新
                          let temp_str = JSON.stringify(Object(this.product_rule)[item]); //序列化
                          Object(this.product_rule)[item] = JSON.parse(temp_str); //反序列化
                        })
                    })
                  }
                }
              })
            }
          .width("100%")
          .margin({ top: 30 })
          .padding({ left: 10, right: 10 })
          .alignItems(HorizontalAlign.Start)

          // 5.商品数量/步进器
          Row() {
            // 左边数量
            Text("选择数量")
            Row() {
              // 右边步进器
              Button("-")
                .width(24)
                .height(24)
                .padding(0)
                .backgroundColor(Color.White)
                .fontColor(Color.Red)
                .border({
                  width: 1,
                  color: Color.Red,
                  style: BorderStyle.Solid
                })
                .type(ButtonType.Circle)
                .onClick(()=>{
                  //数量减
                  let i = Number(this.count)
                  //边界控制，小于1就等于1，否则正常
                  this.count = --i < 1 ? "i": String(i);
                })

              TextInput({ text: $$this.count })
                .width(50)
                .type(InputType.Number)
                .textAlign(TextAlign.Center)
                .backgroundColor(Color.White)
                .padding(0)
                .onChange((v:string) =>{
                  if (new RegExp(/^0/).test(v)){
                   v = v.slice(1);
                  }
                  this.count = v;
                })
                .onBlur(()=>{
                  this.count = this.count == "" ? "1" :this.count;
                })

              Button("+")
                .width(24)
                .height(24)
                .padding(0)
                .backgroundColor(Color.Red)
                .type(ButtonType.Circle)
                .onClick(()=>{
                  let i = Number(this.count);
                  this.count = String(++i);
                })
            }
          }
          .width("100%")
          .padding({
            left: 10,
            right: 10,
            top: 20,
            bottom: 20
          })
          .margin({ top: 20, bottom: 20 })
          .border({
            width: { top: 1, bottom: 1 },
            color: "#ddd"
          })
          .justifyContent(FlexAlign.SpaceBetween)

          // 6.商品描述
          Column() {
            Text("商品描述").margin({ bottom: 20 })
            Text(this.product_detail[0]?.desc)
          }
          .alignItems(HorizontalAlign.Start)
          .width("100%")
          .padding({ left: 10, right: 10 })
        }
        .width("100%")
      }
      .height("calc(100% - 110vp)")
      .padding({ bottom: 20 })

      //7.底部按钮
      Row({ space: 10 }) {
        Badge({
          count:this.badge_count,
          // value:"NEW",
          style:{
            badgeSize:14,
            fontSize:10,
            badgeColor:"#FA2A20"
          },
          // position:BadgePosition.RightTop
          position:{x:30,y:0}
        })
        Column() {
          Image($r("app.media.shopbag")).width(20)
          Text("购物袋")
        }.onClick(()=>{
          router.pushUrl({
            url:"pages/Index"
          })
        })

        Column() {
          Image(this.is_like? $r("app.media.like") : $r("app.media.like_o")).width(20)
          Text("收藏")
        }.onClick(()=>{
          //如果没有登录，去登录
          if(!this.user_token.length){
            promptAction.showToast({
              //显示吐司
              message:"还未登录，请先登录"
            })
            //去登录页
            router.pushUrl({
              url:"pages/LoginPage"
            })
          }
          //登录了
          else {
            toggleLike(this.is_like, this.pid, this.user_token)
              .then(res => {
                console.log("切换收藏的方法=>", JSON.stringify(Object(res).result))
                if(Object(res).result.code == 800 || Object(res).result.code == 900) {
                  this.is_like = !this.is_like
                }
              })
              .catch((err: BusinessError) => {
                console.error('收藏接口失败', err.code, err.message);
              });
          }
        })

        Button("加入购物袋").onClick((event:ClickEvent) =>{
        })
          .layoutWeight(1)
          .backgroundColor($r("app.color.theme_color"))
          .onClick(() => {
            //如果没有登录，不能加入购物车，跳转到登录页面
            if (!this.user_token.length) {
              promptAction.showToast({
                message:"还未登录，请先登录"
              })
              router.pushUrl({
                url:"pages/LoginPage"
              })
            }
            //如果登录
            else {
              //加入如购物车 pid count rule token
              //rule: 冰/默认奶油
              let rule_str:string = "";

              //遍历规格对象
              for(let item of Object.keys(this.product_rule)){
                let arr:string[] = Object(this.product_rule)[item].arr;
                let idx:number = Object(this.product_rule)[item].idx;

                rule_str += arr[idx] + "/";
              }
              //去掉最后一个"/"
              rule_str = rule_str.slice(0,-1)
              console.log("当前选中的规格是 =>",rule_str)
              //添加购物车
              addShopcart(this.pid,this.count,rule_str,this.user_token)
                .then( res=>{
                  console.log("添加购物车的结果",JSON.stringify(Object(res).result));
                  //1添加商品，0增加数量
                  if (Object(res).result.status ==1) {
                    this.badge_count++
                    promptAction.showToast({
                      message:"添加商品成功"
                    })
                  }else if(Object(res).result.status == 0){

                    promptAction.showToast({
                      message:"商品数量增加"
                    })
                  }
                })
            }
          })
          .layoutWeight(1)
      }
      .width("100%")
      .height(45)
      .margin({ top: 9 })
      .padding({ left: 10, right: 10 })
    }
  }
}
