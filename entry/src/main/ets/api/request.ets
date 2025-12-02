//网络请求接口
//1.导入http模块
import { http } from '@kit.NetworkKit';

//每一个接口都需要的appkey
const APPKEY = "U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=";

//在当前项目里面,post请求的传参,需要以表单的结构传递参数: 参数1=值 & 参数2=值2 & 参数3=值3 &...
//{参数1:值,参数2:值,参数3:值,...} => 参数1=值 & "参数2=值2 & 参数3=值3 &..."
function queryString(obj: object) {
  //获取到对象的key => [nickName, password, phone]
  let keys: string[] = Object.keys(obj);

  //初始化字符串,用于拼接请求参数
  let str: string = "";

  //for(const 数组项 of 原数组)
  for (const item of keys) {
    // str += item + "=" + obj[item] + "&";
    str += `${item}=${obj[item]}&`
    // `${str}${item}=${obj[item]}&`
  }
  //切除最后一个&
  str = str.slice(0, -1)

  console.log("现请求参数 =>", str);
  return str;
}

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
  console.log("原请求参数 =>", JSON.stringify(Object(params)))

  //构建一个 请求参数
  let param: object|string = params;

  //如果是post请求,需要序列号请求参数:
  if (method == "post") {
    param = queryString(params)
  }


  //3.用请求实例 发起网络请求 => 请求实例.request("api",配置对象)
  // let result = httpRequest.request(url, {
  return httpRequest.request(url, {
    //请求方式:get/post/put请求
    //三元运算符
    method: method == "get" ? http.RequestMethod.GET : http.RequestMethod.POST,
    //请求头
    header: {
      // "Content-Type": "application/json"
      //原本的参数:参数1:值,参数2:值,参数3:值
      //在当前项目里面,post请求的传参,需要以表单的结构传递参数: 参数1=值 & 参数2=值2 & 参数3=值3 &...
      "Content-Type": "application/x-www-form-urlencoded"
    },

    //请求参数
    // extraData: params,
    extraData: param,

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

