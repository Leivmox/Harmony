//数据类型约束

//接口： 约束对象格式
export interface userMsg {
  phone:rule,
  password: rule,
  nickName?: rule
}

//定义接口
export interface rule{
  val: string,  //当前属性的值
  regexpRule: RegExp,  //当前属性的匹配规则
  errMsg: string  //验证不通过的提示
}


// tabBar所需要的数据
export interface tabBarDataItemType {
    title: string
    img: Resource
    img_active: Resource
  }

  //首页数据约束 begin****************************
  //首页轮播图数据格式
export interface bannerResultType {
  code: number;
  result: bannerItemType[];
}

export interface bannerItemType {
  bannerImg: string;
  name: string;
  pid: string;
}
//首页商品列表的数据格式
export interface productListType{
  code: number;
  result:productItem[];
}

export interface productItem {
  createdAt:string;
  desc: string;
  enname: string;
  id:number;
  isHot:number;
  largeImg:string;
  name:string;
  pid:string;
  price:string;
  smallImg:string;
  type:string;
  typeDesc:string;
  updateAt:string;
}
//首页数据约束 end***************************

//菜单页数据约束 begin
export interface sideBarType{
  code:number;
  result:sideBarItem[];
}

export interface sideBarItem{
  createdAt:string;
  id:number;
  type:string;
  typeDesc:string;
  updatedAt:string;
}

//搜索页数类型 begin ************************
export interface searchProductType {
  code: string;
  msg: string;
  result: searchProductItem[];
}

export interface searchProductItem {
  createdAt: string;
  desc: string;
  enname: string;
  id: number;
  isHot: number;
  largeImg: string;
  name: string;
  pid: string;
  price: string;
  smallImg: string;
  type: string;
  typeDesc: string;
  updatedAt: string;
}

//详情页数据类型
export interface productDetailResponse {
  code: number;
  msg: string;
  result: productDetailType[];
}

export interface productDetailType {
  cream: string;
  cream_desc: string;
  desc: string;
  enname: string;
  is_hot: number;
  large_img: string;
  milk: string;
  milk_desc: string;
  name: string;
  pid: string;
  price: string;
  small_img: string;
  sugar: string;
  sugar_desc: string;
  tem: string;
  tem_desc: string;
  type: string;
  type_desc: string;
}

//商品规格的接口
export interface product_rule {
  sugar?: product_rule_item
  cream?: product_rule_item
  milk?: product_rule_item
  tem?: product_rule_item
}
export interface  product_rule_item{
  arr?:string[], // 右边的按钮
  idx?: number, // 默认选中
  desc?:string // 左边的描述
}

// 购物袋的数据约束
export interface shopBagResponse {
  code: number;
  msg: string;
  result: shopBagItem[];
}

export interface shopBagItem {
  count: number;
  created_at: string;
  desc: string;
  enname: string;
  is_hot: number;
  is_remove: number;
  large_img: string;
  name: string;
  pid: string;
  price: string;
  rule: string;
  sid: string;
  small_img: string;
  status: number;
  type: string;
  type_desc: string;
  updated_at: string;
  user_id: string;
}