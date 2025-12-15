
/**
 * @description 防抖函数
 * @func 要执行的函数
 * @awit 等待的时长：毫秒数  在这个时长内不会重复执行函数
 */
export const debounce = (func:Function, awit:number)=>{
  // 私有成员 -- 定时器编号
  let timeout: number | null = null;

  return (token:string, sid:string, count:string)=>{
    // 清除定时器
    clearTimeout(timeout)
    // 给定时器编号赋值
    timeout = setTimeout(()=>{
      // 清除定时器
      clearTimeout(timeout)
      func(token, sid, count)
    }, awit)
  }
}


