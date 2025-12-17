//
// /**
//  * @description 防抖函数
//  * @func 要执行的函数
//  * @awit 等待的时长：毫秒数  在这个时长内不会重复执行函数
//  */
// export const debounce = (func:Function, awit:number)=>{
//   // 私有成员 -- 定时器编号
//   let timeout: number | null = null;
//
//   return (token:string, sid:string, count:string)=>{
//     // 清除定时器
//     clearTimeout(timeout)
//     // 给定时器编号赋值
//     timeout = setTimeout(()=>{
//       // 清除定时器
//       clearTimeout(timeout)
//       func(token, sid, count)
//     }, awit)
//   }
// }
//
//
/**
 * @description 通用防抖函数 (兼容有参/无参)
 * @param func 要执行的函数
 * @param wait 等待时间(ms)
 */
export function debounce(func: Function, wait: number) {
  let timer: number | null = null;

  // 使用联合类型代替 any，这样 ArkTS 就不会报错了，同时也支持传参
  return (...args: (string | number | boolean | object)[]) => {
    if (timer) {
      clearTimeout(timer);
    }
    timer = setTimeout(() => {
      // 这里的 ...args 会自动传给你的业务函数 (func)
      func(...args);
    }, wait);
  }
}
