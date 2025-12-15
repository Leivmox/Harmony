//网络请求接口
import { http } from "@kit.NetworkKit";
import { request } from "./request";


/**
 * @description 注册接口，http://apis.netstart.cn/coffee/register,POST
 * @param phone: 手机号
 * @param password: 密码,
 * @param nickName: 昵称,
 * @returns
 */
export function register(phone: string, password: string, nickName: string): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/register", "post", Object({
    phone,
    password,
    nickName
  }))
}

/**
 * @description 注册接口，http://apis.netstart.cn/coffee/login,POST
 * @param phone: 手机号
 * @param password: 密码,
 * @returns
 */
//登录接口
export function login(phone: string, password: string): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/login", "post", Object({
    phone,
    password
  }))
}

//轮播图接口
// banner接口
// 请求地址：http://apis.netstart.cn/coffee/banner
// 请求类型： GET
// 请求参数： {
//   appkey: 你的appkey
// }
export function banner(): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/banner", "get", Object({}))
}

//首页商品数据
// 根据商品类型获取商品接口
// 请求地址：/typeProducts
//   请求类型： GET
// 请求参数： {
//   key: 'isHot',
//   value: 1
// }
export function homeProductList(): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/typeProducts", "get", Object({
    key: "isHot",
    value: "1"
  }))
}

// 商品类型接口
// 请求地址：http://apis.netstart.cn/coffee/type
// 请求类型： GET
// 请求参数： {
//   appkey: 你的appkey
// }
export function menuSideBar(): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/type", "get", Object({}))
}

// 根据商品类型获取商品接口
// 请求地址：http://apis.netstart.cn/coffee/typeProducts
//   请求类型： GET
// 请求参数： {
//   appkey: 你的appkey,
//   key: '商品类型键名',
//   value: '商品类型值'
// }
export function menuProductList(val: string): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/typeProducts", "get", Object({
    key: 'type',
    value: val
  }))
}

// 搜索商品接口
// 请求地址：http://apis.netstart.cn/coffee/search
// 请求类型： GET
// 请求参数： {
// appkey: 你的appkey,
// name: 商品关键字
// }
export function searchProduct(val: string): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/search", "get", Object({
    name: val
  }))
}

// 查看商品详情接口
// 请求地址：http://apis.netstart.cn/coffee/productDetail
//   请求类型： GET
// 请求参数： {
//   appkey: 你的appkey,
//   pid: 商品pid
// }
export function productDetail(pid: string): Promise<http.HttpResponse> {
  //发起网络请求
  return request("/productDetail", "get", Object({
    pid: pid
  }))
}

// 收藏商品接口 请求地址：http://apis.netstart.cn/coffee/like
// 取消(删除)收藏商品接口 请求地址：http://apis.netstart.cn/coffee/notlike
// 请求类型： POST
// 请求参数： {
//   appkey: 你的appkey,
//   pid: 商品pid,
//   tokenString: token字符串
// }

export function toggleLike(current_state: boolean, pid: string, token: string): Promise<http.HttpResponse> {
  //当前商品是收藏状态刷取消收藏，当前为收藏状态则收藏
  let url = current_state ? "/notlike" : "/like";
  return request(url, "post", Object({
    pid: pid,
    tokenString: token
  }))
}

// 查询收藏商品接口
// 请求地址：http://apis.netstart.cn/coffee/findlike
//   请求类型： GET
// 请求参数： {
//   appkey: 你的appkey,
//   pid: 商品pid,
//   tokenString: token字符串
// }

export function findLike(pid: string, token: string): Promise<http.HttpResponse> {
  return request("/findlike", "get", Object({
    pid: pid,
    tokenString: token
  }))
}

// 查询用户所有收藏商品接口
// 请求地址：http://apis.netstart.cn/coffee/findAllLike
//   请求类型： GET
// 请求参数： {
//   appkey: 你的appkey,
//   tokenString: token字符串
// }

export function findAllLike(token: string): Promise<http.HttpResponse> {
  return request("/findAllLike", "get", Object({
    tokenString: token
  }))
}

/**
 * @description添加购物车的方法
 * @param pid 添加id
 * @param count 添加数量
 * @param rule 商品规格，如：无糖/默认奶油
 * @param token 用户token
 * @returns
 */
export function addShopcart(pid:string,count:string,rule:string,token:string):Promise<http.HttpResponse>{
  return request("/addShopcart","post",Object({
    pid,
    count,
    rule,
    tokenString:token
  }))
}

// 获取购物车商品条目 (不是商品总数量)
// 请求地址：http://apis.netstart.cn/coffee/shopcartRows
//   请求类型： GET
// 请求参数： {
//   tokenString: token字符串
// }
export function shopcartRows(token:string):Promise<http.HttpResponse>{
  return request("/shopcartRows","get",Object({
    tokenString:token
  }))
}

// 查询用户所有购物车条数接口
// 请求地址：http://apis.netstart.cn/coffee/findAllShopcart
// 请求类型： GET
// 请求参数： {
// tokenString: token字符串
// }
export function findAllShopcart(token:string):Promise<http.HttpResponse>{
  return request("/findAllShopcart","get",Object({
    tokenString:token
  }))
}

// 修改购物车商品数量接口
// 请求地址：http://apis.netstart.cn/coffee/modifyShopcartCount
//   请求类型： POST
// 请求参数： {
//   appkey: 你的appkey,
//   tokenString: token字符串,
//   sid: 购物车唯一标识,
//   count: 商品数量
// }

export function modifyShopcartCount(token:string,sid:string,count:string):Promise<http.HttpResponse>{
  return request("/modifyShopcartCount","post",Object({
    tokenString:token,
    sid,
    count
  }))
}

// 删除 一个或者多个 购物车商品接口 该接口为：逻辑删除(假删除，数据仍在数据库中，但不能查询，以便后续客服手动恢复)
// 请求地址：http://apis.netstart.cn/coffee/removeShopcart
//   请求类型： POST
// 请求参数： {
//   appkey: 你的appkey,
//   tokenString: token字符串,
//   sids: sid购物车唯一标识集合字符串
// }
//
// 其中 sids 值为 JSON.stringify([sid1, sid2, sid3])
export function removeShopcart(token:string, sids:string ):Promise<http.HttpResponse>{
  return request("/removeShopcart","post", Object({
    tokenString: token,
    sids
  }))
}
