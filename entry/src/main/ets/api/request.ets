// 项目文档地址: https://apis.netstart.cn/coffee/#/
// 接口补全地址: https://kf.webxyq.com
// 1.导入http模块
import { http } from '@kit.NetworkKit'

//每一个接口都需要的appkey
const APPKEY = "U2FsdGVkX19WSQ59Cg+Fj9jNZPxRC5y0xB1iV06BeNA=";
const BASEURL = "https://kf.webxyq.com";

function queryString(obj: object) {
  //获取到对象的key => [nickName,password,phone]
  let keys: string[] = Object.keys(obj)

  //初始字符串，用于拼接请求参数
  let str: string = "";

  for (const item of keys) {
    str += `${item}=${obj[item]}&`;
  }

  str = str.slice(0, -1)
  return str;
}

/**
 * @description 封装的网络请求方法
 * @param url 请求地址
 * @param method 请求方式
 * @param params 请求参数
 */
export function request(url: string, method: string, params: object) {
  //2.创建一个请求实例(一个请求实例对应一个网络请求，请求完成，对应的实例要销毁)
  let httpRequest = http.createHttp();

  //添加通用appkey请求参数
  Object(params).appkey = APPKEY;
  console.log("请求参数 =>", JSON.stringify(Object(params)))

  //请求参数
  let param: object | string = params;

  //如果是post请求，需要序列化请求参数：{参数1：值，参数2：值，参数3：值...}=>"参数1=值& 参数2=值& 参数3=值&”
  if (method == "post") {
    param = queryString(params)
  }

  //3.用请求实例 发起网络请求 => 请求实例.request("api",配置对象)
  return httpRequest.request(BASEURL + url, {
    //请求方式 get/ post/ put请求
    method: method == "get" ? http.RequestMethod.GET : http.RequestMethod.POST,
    //请求头
    header: {
      //在本项目，post请求的参数，以表单结构传递参数:参数1=值& 参数2=值& 参数3=值....
      "Content-Type": "application/x-www-form-urlencoded;"
    },
    //请求参数
    extraData: param,
    //返回的数据结构
    expectDataType: http.HttpDataType.OBJECT
  })
    .finally(() => {
      //销毁网络请求实例
      httpRequest.destroy();
    })
  /*
  请求的结果 result 是一个 Promise对象
  （Promise对象）
    .then（(res）=>{res请求成功返回的数据 })
    .catch( (err)=>{ err请求失败返回的失败信息  }）
    .finally(()=>{请求完成执行的方法}）
  */
}