//网络请求接口:移动到request.ets
import { request } from './request';
import { http } from '@kit.NetworkKit';

//测试接口 一言
export function hitokoto(): Promise<http.HttpResponse> {
  return request("https://v1.hitokoto.cn", "get", Object());
}

//注册接口
export function register(phone: string, password: string, nickName: string): Promise<http.HttpResponse> {

  //o2不需要接口 (取巧)
  // let o = {};
  // let o2:object = Object({})

  //发起网络请求
  return request("https://kf.webxyq.com/register", "post", Object({
    phone,
    password,
    nickName
  }))
}

//登录接口
export function login(phone: string, password: string, nickName: string): Promise<http.HttpResponse> {

  //发起网络请求
  return request("https://kf.webxyq.com/login", "post", Object({
    phone,
    password
  }))
}
//轮播图接口
//商品数据接口
