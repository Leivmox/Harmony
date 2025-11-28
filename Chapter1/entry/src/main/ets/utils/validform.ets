import { userMsg, rule } from '../model/model';
import { PromptAction } from '@kit.ArkUI';

// import { PromptAction } from '@ohos.arkui.UIContext';
//
// let PromptAction = this.get

// 表单验证
export function vaildForm(vaild_obj:userMsg, promptAction: PromptAction): boolean {

  //开始验证
  //获取对象的 key,确定要验证的输入框
  let keys: string[] = Object.keys(vaild_obj); //拿到了对象键名的字符串数组

  //假设所有表单都验证通过
  let flag: boolean = true;

  for (const item of keys) {
    // console.log("对象的键名=> ", item);

    // console.log("当前属性的值", JSON.stringify(Object(vaild_obj
    //)[item]));

    //拿到当前属性的值(子对象)
    let obj: rule = Object(vaild_obj)[item];

    //验证值是否符合规则  => 语法:正则.test("要验证的值")
    if (!obj.regexpRule.test(obj.val)) {
      //某个输入框不通过,输出当前错误信息,flag假设不成立,跳出循环
      console.log(obj.errMsg);
      //显示错误信息
      promptAction.showToast({message: obj.errMsg})
      flag = false;
      break;
    }

    // if(flag){
    //   console.log("表单验证通过")
    //   //真正的注册逻辑
    // }
  }
  return flag;
}