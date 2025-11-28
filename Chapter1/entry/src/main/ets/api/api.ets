
//网络请求接口:移动到request.ets
import { request } from './request'
import { http } from '@kit.NetworkKit';

//测试接口
export function hitokoto(): Promise<http.HttpResponse>{
  return request("https://v1.hitokoto.cn","get","");
}
//注册接口
//登录接口
//轮播图接口
//商品数据接口
