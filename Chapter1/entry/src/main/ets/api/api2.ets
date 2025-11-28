//来自AI的现代网络请求结构

//网络请求接口
//1.导入http模块
import { http } from '@kit.NetworkKit';

// 1. 函数必须加上 async 关键字
export async function testRequest2() {

  let httpRequest = http.createHttp();

  try {
    // 2. 必须加上 await 等待结果
    let response = await httpRequest.request("https://v1.hitokoto.cn", {
      method: http.RequestMethod.GET,
      header: {
        "Content-Type": "application/json"
      },
      expectDataType: http.HttpDataType.OBJECT
    });

    // 3. 处理结果：判断状态码
    if (response.responseCode === 200) {
      // 实际数据在 response.result 中
      console.info("请求成功:", JSON.stringify(response.result));
    } else {
      console.error("请求失败, 状态码:", response.responseCode);
    }

  } catch (err) {
    // 4. 捕获网络错误（如断网、超时）
    let error = err as BusinessError;
    console.error("网络请求异常:", error.message);
  } finally {
    // 5. 必须销毁实例 (无论成功失败都要执行)
    httpRequest.destroy();
  }
}