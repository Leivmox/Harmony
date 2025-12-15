// 数据接口
import { findAllShopcart, modifyShopcartCount, removeShopcart } from "../api/api"
// 购物车数据类型约束
import { shopBagItem } from "../model/model"

import { delStorage, getStorage } from "../utils/storage";
import { router } from "@kit.ArkUI";

import {
  debounce
} from "../utils/debounce"


/**
 * @description 修改购物车商品数量(防抖)  f = (token:string, sid:string, count:string)=>{}
 * @param token 用户token,
 * @param sid 购物车商品id,
 * @param count 商品数量
 * @return
 */
let f = debounce( (token:string, sid:string, count:string)=>{
  modifyShopcartCount(token, sid, count)
    .then( res=>{
      console.log("修改购物车数量(接口版) =>", JSON.stringify(Object(res).result));
    })
},  500 );


// 自定义组件
@Entry
  // TODO:..
@Component
export default struct ShopBag {
  // 购物袋商品列表
  @State shopbag_list: shopBagItem[] = [];
  // 商品列表对应的商品数量
  @State count_arr: number[] = [];

  // 自定义构建函数 -- 列表的划出组件
  @Builder itemEnd( idx:number, onClick:()=>void ){
    Text("删除")
      .padding(5)
      .fontSize(16)
      .fontColor(Color.White)
      .textAlign(TextAlign.Center)
      .width(60)
      .height("100%")
      .backgroundColor(Color.Red)
      .borderRadius({topRight: 10, bottomRight: 10})
      .onClick(onClick)
  }

  // 用户token
  private user_token: string = "";

  // 获取购物车商品
  private findAllShopcart() {
    // 已经登录，查购物车商品
    if (this.user_token.length) {
      findAllShopcart(this.user_token)
        .then(res => {
          // 获取到商品数据， 赋值给购物车商品列表
          this.shopbag_list = Object(res).result.result;
          console.log("购物车商品数据 =>", JSON.stringify(this.shopbag_list))

          // 局部变量（数量数组）， 这里是数组映射 map， 把原数组的某个值，经过处理，映射成一组新的数组
          let count_arr:number[] = this.shopbag_list.map((v:shopBagItem)=>{
            return v.count;
          })
          // 一次性赋值给状态遍历
          this.count_arr = count_arr;
          console.log("每一件商品的数量 =>", JSON.stringify(count_arr))
        })
    }
  }

  // 生命周期 页面即将显示
  aboutToAppear() {
    // 获取token
    this.user_token = getStorage("user_token") as string;
    // 获取购物车商品
    this.findAllShopcart();
  }

  // 页面结构
  build() {
    Column() {

      // 1. 顶部导航
      Row() {
        Text("< 返回").fontColor($r("app.color.theme_color"))
        Text("购物袋")
        Text("编辑").fontColor($r("app.color.theme_color"))
      }
      .width("100%")
      .height(56)
      .padding({ left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(Color.White)

      // 2. 背景
      Image($r("app.media.shopbag_bg")).width("100%")

      // 3. 滚动视图(购物车商品列表 / 空状态)
      Scroll() {
        Column() {
          // 没有登录
          if (!this.user_token.length) {
            Row() {
              Text("还未登录，先")
              Text("登录")
                .fontColor($r("app.color.theme_color"))
                .onClick(() => {
                  router.pushUrl({
                    url: "pages/LoginPage"
                  })
                })
            }
          }
          // 没有商品
          else if (!this.shopbag_list.length) {
            Text("目前还没有商品")
          }
          // 有商品
          else {

            List(){
              ForEach(this.shopbag_list, (item:shopBagItem, index:number)=>{
                ListItem(){
                  // 每一行商品 左(复选框) 中(图片) 右(描述)
                  Row({space: 10}) {
                    // 左(复选框)
                    Checkbox({ group: "shopbagCheckBox" })
                    // 中(图片)
                    Image(item.small_img)
                      .width(90)
                      .height(90)
                    // 右(描述)
                    Column() {
                      // 上: 名称和规格
                      Row() {
                        Text(item.name)
                          .margin({ right: 20 })
                          .fontSize(14)
                        Text(item.rule).fontSize(14)
                      }
                      // 中: 英文名字
                      Text(item.enname)
                        .width("100%")
                        .fontSize(14)
                        .maxLines(1)
                        .margin({bottom: 20})
                        .textOverflow({overflow:TextOverflow.Ellipsis})

                      //下边
                      Row(){
                        Text("￥"+item.price)
                          .fontSize(14)

                        Row({ space: 10 }) {
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
                            .onClick(() => {
                              // 数量减
                              let i = this.count_arr[index];
                              this.count_arr[index] = --i < 1 ? 1 : i;
                              // 修改购物车数量 （调用防抖函数，不需要每次增减数量都调用接口， 只需要保证最后一次的数量提交）
                              f(this.user_token, this.shopbag_list[index].sid, String(this.count_arr[index]))
                            })

                          TextInput({ text: String(this.count_arr[index]) })
                            .width(50)
                            .type(InputType.Number)
                            .textAlign(TextAlign.Center)
                            .backgroundColor(Color.White)
                            .padding(0)
                            .onChange((v: string) => {
                              if(new RegExp(/^0/).test(v)){
                                v = v.slice(0,-1)
                              }
                              this.count_arr[index] = Number(v) ? Number(v) : 1;
                              // 非空字符串才可以提交
                              if(v){
                                // 修改购物车数量 （调用防抖函数，不需要每次增减数量都调用接口， 只需要保证最后一次的数量提交）
                                f(this.user_token, this.shopbag_list[index].sid, String(this.count_arr[index]))
                              }
                            })
                            // 如果输入框失去焦点，没有数量，数量初始化为1
                            .onBlur(() => {
                              if(!this.count_arr[index]){
                                this.count_arr[index] = 1;
                              }
                            })

                          Button("+")
                            .width(24)
                            .height(24)
                            .padding(0)
                            .backgroundColor(Color.Red)
                            .type(ButtonType.Circle)
                            .onClick(() => {
                              // 数量+
                              let i:number = this.count_arr[index];
                              this.count_arr[index] = ++i;
                              // 修改购物车数量 （调用防抖函数，不需要每次增减数量都调用接口， 只需要保证最后一次的数量提交）
                              f(this.user_token, this.shopbag_list[index].sid, String(this.count_arr[index]))
                            })
                        }
                      }
                      .width("100%")
                      .justifyContent(FlexAlign.SpaceBetween)

                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .padding(10)
                  .backgroundColor(Color.White)
                }.swipeAction({
                  // 设置右边划出组件
                  end: this.itemEnd(index, ()=>{
                    console.log("当前删除的元素的下标是 =>", index)

                    // 需要删除的购物车商品id: [sid1, sid2, sid3]
                    let sids: string[] = [];
                    // 把当前要删除的商品id, 存入数组中
                    sids.push(this.shopbag_list[index].sid)

                    // 删掉当前购物车商品
                    removeShopcart(this.user_token, JSON.stringify(sids))
                      .then( res=>{
                        console.log("删除购物车商品 =>", JSON.stringify(Object(res).result));

                        // 接口调用成功， 数据已经删除
                        if(Object(res).result.code == 7000){
                            // 同步本地购物车列表
                            this.shopbag_list.splice(index, 1)
                        }
                      })
                  }),
                  edgeEffect: SwipeEdgeEffect.Spring
                })
              })
            }

          }
        }
      }
      .width("100%")
      .height("calc(100% - 160.8vp)")

      // 4. 提交订单
      Row({ space: 10 }) {
        // 复选框
        Row() {
          // 全选按钮
          CheckboxGroup({ group: "shopbagCheckBox" })
          Text("全选")
        }

        // 价格
        Row() {
          Text("合计:")
          Text("￥0.00")
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.End)

        Button("提交订单")
          .linearGradient({
            // 线性渐变
            angle: 90,
            colors: [
              [0xfe5d33, 0.2],
              [0xee0d26, 1.0]
            ]
          })
      }
      .padding({ left: 10, right: 10 })
      .backgroundColor(Color.White)
    }

    .height("100%")
    .backgroundColor(0xefefef)
  }
}