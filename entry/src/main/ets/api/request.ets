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
  let httpRequest = http.createHttp();


  let requestParams: Record<string, Object> = {};

  // 1. 将传入的 params 断言为 Record 类型以便遍历
  let srcParams = params as Record<string, Object>;

  // 2. 遍历 key 进行复制 (替代 ...params)
  let keys = Object.keys(srcParams);
  for (let key of keys) {
    requestParams[key] = srcParams[key];
  }

  // 3. 添加 appkey
  requestParams['appkey'] = APPKEY;
  console.info(`[HTTP] 请求: ${url}, 方式: ${method}, 参数: ${JSON.stringify(requestParams)}`);

  let fullUrl = BASEURL + url;
  let finalExtraData: string | Object | undefined = undefined;

  if (method.toLowerCase() === "get") {
    // GET 请求：参数拼接到 URL 后面
    const strParam = queryString(requestParams);
    if (strParam) {
      // 判断 url 是否已经包含了 '?'
      if (fullUrl.includes('?')) {
        fullUrl += `&${strParam}`;
      } else {
        fullUrl += `?${strParam}`;
      }
    }
    // GET 请求 extraData 必须为空 (undefined)
  } else {
    // POST 请求：参数序列化后放在 extraData 中
    finalExtraData = queryString(requestParams);
  }

  // 发起请求
  return httpRequest.request(fullUrl, {
    method: method.toLowerCase() === "get" ? http.RequestMethod.GET : http.RequestMethod.POST,
    header: {
      "Content-Type": "application/x-www-form-urlencoded"
    },
    extraData: finalExtraData,
    expectDataType: http.HttpDataType.OBJECT
  })
    .finally(() => {
      httpRequest.destroy();
    })
}
