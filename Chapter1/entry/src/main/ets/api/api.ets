//网络请求接口
//1.导入http模块
import { http } from '@kit.NetworkKit'

//2.创建一个请求实例(一个请求实例对应一个网络请求,请求完成,对应的实例要销毁)
let httpRequest = http.createHttp();

//3.用请求实例 发起网络请求
httpRequest.request("",{
  method: http.RequestMethod.GET,
  //请求头
  header:{
    "Content-Type":"application/json"
  },

  //请求参数
  extraData:{},

  //返回的数据结构
  expectDataType: http.HttpDataType.OBJECT

})