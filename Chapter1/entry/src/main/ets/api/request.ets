//网络请求接口
//1.导入http模块
import { http } from '@kit.NetworkKit';

//每一个接口都需要的appkey
const APPKEY = "U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=";


//测试接口
/**
 * @descript 封装的网络请求方法
 * @param url 请求地址
 * @param method 请求方式
 * @param params 请求参数
 */
export function request(url: string, method: string, params: object) {

  //2.创建一个请求实例(一个请求实例对应一个网络请求,请求完成,对应的实例要销毁)
  let httpRequest = http.createHttp();

  //两种网络请求:(async简单一点)
  //new Promise
  //async await


  Object(params).appkey = APPKEY;
  console.log("请求参数 =>",JSON.stringify(Object(params)))


  //3.用请求实例 发起网络请求 => 请求实例.request("api",配置对象)
  // let result = httpRequest.request(url, {
  return httpRequest.request(url, {
    //请求方式:get/post/put请求
    //三元运算符
    method: method == "get" ? http.RequestMethod.GET : http.RequestMethod.POST,
    //请求头
    header: {
      "Content-Type": "application/json"
    },

    //请求参数
    extraData: params,

    //返回的数据结构
    expectDataType: http.HttpDataType.OBJECT

  })
  //请求完成,销毁实例
    .finally(() => {
      //销毁实例
      httpRequest.destroy();
    })

  //返回网络请求的结果[object Promise]
  // return result;
  // console.log("请求结果 => ", result)
  // /*
  // (Promise对象)
  //   .then( (res)=>{ res请求成功返回的数据 })
  //   .catch（ (err)=>{ err请求失败返回的失败信息 })
  //  */
  // result
  //   .then(res => {
  //     console.log("请求成功 =>", JSON.stringify(res))
  //   })
  //   .catch((err: Object) => {
  //     console.log("请求失败 =>", err)
  //   })
  //   .finally(() => {
  //     httpRequest.destroy();
  //   });
}
