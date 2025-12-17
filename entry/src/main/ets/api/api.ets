//网络请求接口
import { http } from '@kit.NetworkKit';
import { request } from './request';


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
export function addShopcart(pid: string, count: string, rule: string, token: string): Promise<http.HttpResponse> {
  return request("/addShopcart", "post", Object({
    pid,
    count,
    rule,
    tokenString: token
  }))
}

// 获取购物车商品条目 (不是商品总数量)
// 请求地址：http://apis.netstart.cn/coffee/shopcartRows
//   请求类型： GET
// 请求参数： {
//   tokenString: token字符串
// }
export function shopcartRows(token: string): Promise<http.HttpResponse> {
  return request("/shopcartRows", "get", Object({
    tokenString: token
  }))
}

// 查询用户所有购物车条数接口
// 请求地址：http://apis.netstart.cn/coffee/findAllShopcart
// 请求类型： GET
// 请求参数： {
// tokenString: token字符串
// }
export function findAllShopcart(token: string): Promise<http.HttpResponse> {
  return request("/findAllShopcart", "get", Object({
    tokenString: token
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

export function modifyShopcartCount(token: string, sid: string, count: string): Promise<http.HttpResponse> {
  return request("/modifyShopcartCount", "post", Object({
    tokenString: token,
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
export function removeShopcart(token: string, sids: string): Promise<http.HttpResponse> {
  return request("/removeShopcart", "post", Object({
    tokenString: token,
    sids
  }))
}

/**
 * @description 修改密码接口
 * 请求地址：http://apis.netstart.cn/coffee/updatePassword
 * 请求类型： POST
 * @param token: 用户token
 * @param newPassword: 新密码
 * @param oldPassword: 旧密码
 */
export function updatePassword(token: string, newPassword: string, oldPassword: string): Promise<http.HttpResponse> {
  return request("/updatePassword", "post", Object({
    tokenString: token,
    password: newPassword,
    oldPassword: oldPassword
  }))
}

/**
 * @description 获取个人资料（昵称、头像、简介等）
 * 请求地址：http://apis.netstart.cn/coffee/findAccountInfo
 * 请求类型： GET
 */
/**
 * 个人资料信息结构
 * 根据接口文档和通常的返回习惯定义
 */
export interface UserInfo {
  nickName: string;
  desc: string;
  userImg: string;
  // 新增下面这两个字段，使用 ? 表示可选
  phone?: string;
  userId?: string;
}

/**
 * 通用API响应结构 (用于解决 strict mode 下 res.result.code 报错的问题)
 */
export interface ApiResponse<T = Object> {
  code: string | number; // 有些接口返回 200(number), 有些返回 "200"(string)
  msg: string;
  result: T; // 使用泛型，灵活定义 result 的类型
}

/**
 * @description 获取个人资料（昵称、头像、简介等）
 * 请求地址：http://apis.netstart.cn/coffee/findAccountInfo
 * 请求类型： GET
 * 参数：tokenString
 */
export function findAccountInfo(token: string): Promise<http.HttpResponse> {
  return request("/findAccountInfo", "get", Object({
    tokenString: token
  }))
}

/**
 * @description 新增地址接口
 * 请求地址：http://apis.netstart.cn/coffee/addAddress
 * 请求类型： POST
 */
export interface AddressParams {
  tokenString: string;
  name: string;
  tel: string;
  province: string;
  city: string;
  county: string;
  addressDetail: string;
  areaCode: string;
  postalCode: string;
  isDefault: number; // 0 or 1
}

export function addAddress(params: AddressParams): Promise<http.HttpResponse> {
  return request("/addAddress", "post", params);
}
/**
 * @description 查询地址接口
 * 请求地址：http://apis.netstart.cn/coffee/findAddress
 * 请求类型： GET
 * @param token: 用户token
 */
export function findAddress(token: string): Promise<http.HttpResponse> {
  // 根据文档，参数名是 tokenString
  return request("/findAddress", "get", Object({
    tokenString: token
  }))
}

// 1. 根据aid查询地址详情 (用于回显数据)
export function findAddressByAid(aid: string, token: string): Promise<http.HttpResponse> {
  return request("/findAddressByAid", "get", Object({
    aid: aid,
    tokenString: token
  }))
}

// 2. 编辑地址接口 (保存修改)
export function editAddress(params: Object): Promise<http.HttpResponse> {
  return request("/editAddress", "post", params)
}

// 3. 删除地址接口
export function deleteAddress(aid: string, token: string): Promise<http.HttpResponse> {
  return request("/deleteAddress", "post", Object({
    aid: aid,
    tokenString: token
  }))
}

/**
 * @description 修改昵称接口
 * 请求地址：http://apis.netstart.cn/coffee/updateNickName
 * 请求类型： POST
 */
export function updateNickName(token: string, newName: string): Promise<http.HttpResponse> {
  return request("/updateNickName", "post", Object({
    tokenString: token,
    nickName: newName
  }))
}

/**
 * @description 修改简介接口
 * 请求地址：http://apis.netstart.cn/coffee/updateDesc
 * 请求类型： POST
 */
export function updateDesc(token: string, newDesc: string): Promise<http.HttpResponse> {
  return request("/updateDesc", "post", Object({
    tokenString: token,
    desc: newDesc
  }))
}

