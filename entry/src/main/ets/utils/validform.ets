import { userMsg,rule} from '../model/model';
//导入即使反馈模块
import { PromptAction } from '@kit.ArkUI';


// 表单验证工具(要验证的表单数据对象，即使反馈对象)
 export function  validForm(valid_obj: userMsg,promptAction:PromptAction): boolean{
   //开始验证

   //获取对象的key，确定要验证的输入框
   let keys: string[] = Object.keys(valid_obj); //["phone','password','nickName']

   //假设所有的表单都是验证通过的
   let flag: boolean = true;

   //遍历每一个需要验证的数据
   for (const item of keys){

     //拿到当前属性的值 （子对象）
     let obj: rule = Object(valid_obj)[item];

     //验证当前属性的值是否符合正则规则 => 语法： 正则，test（”要要验证的值“） 返回 boolean
     //如果当前的验证不通过
     if(! obj.regexpRule.test( obj.val ) ){
       //显示错误信息
       promptAction.showToast({
         message:obj.errMsg
       })
       //假设不成立，有一个验证不通过
       flag = false;
       //跳出循环
       break;
     }
   }
   //如果表单验证通过
   // console.log("表单验证通过")
   return flag;
 }