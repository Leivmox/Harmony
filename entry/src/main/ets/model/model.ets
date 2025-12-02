//数据类型约束

//表单验证的类型约束
//接口:约束对象格式
export interface userMsg {//用export导出
  phone: rule,
  password: rule,
  nickname?: rule

}

//定义一个接口,
export interface rule {
  val: string, //当前属性原本的值
  regexpRule: RegExp, //当前属性的匹配规则
  errMsg: string //当前属性的错误信息(验证不通过的提示)
}


//tabBar所需的的类型约束
export interface tabBarDataItemType{
  title: string
  img:Resource
  img_active: Resource
}