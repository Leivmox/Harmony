// ArkTs代码 -- 基础语法
// ArkTs 是基于 TypeScript 拓展的语言
// TypeScript是JavaScript的超集， 具有严格的类型约束

// 1.变量： 存储数据的容器   =>   let 变量名:类型 = 值;
let str: string = "hello world";
str = "你好世界";

// 2.常量： 只读变量   =>  const 常量名:类型 = 值;
const COUNT: number = 5;

// 3. 输出语句
console.log(str); // 只能输出字符串
console.log("str =>", str, COUNT); // str => 你好世界 5

// 4. 可变类型   =>  let 变量名: 类型1 | 类型2 |类型3 = 值;
let i: string | number | boolean | null = null;
i = "abc";
i = 33;

// 5. 数组
// 语法1 =>  let 数组名: 类型[] = 值;
let arr1: string[] = ["张三", "李四", "王五"];
let arr2: number[] = [5, 4, 3, 2, 1];
let arr3: (string | number | null | boolean)[] = ["张三", null, 1, true];

// 语法2(泛型) =>  let 数组名: Array<类型> = 值;
let arr4: Array<string> = ["张三", "李四", "王五"];
let arr5: Array<string | number | null | boolean> = [];

// 数组长度  arr.length
console.log("数组长度 =>", arr1.length);
// 获取数组项 => arr[下标]
console.log("arr1[2] =>", arr1[2]);


// 6. 函数  =>  function 函数名(参数:类型, 参数:类型):函数返回值的类型 { }
// 声明一个没有返回值的函数
function fn1(): void {
}

// 声明一个有参数 没有返回值的函数
function fn2(num1: number, num2: number): void {
}

// 有参数有返回值
function fn3(num1: number, num2: number): (number | string) {
  return num1 + num2;
}

// 7. 接口: 约束对象的结构类型  (接口只是一种形状)
interface Person {
  name: string
  age: number
  weight: number
  eat1: () => string
  eat2?: (food: string) => void
}

// 6. 对象
let hippopotamus: Person = {
  name: "河马",
  age: 18,
  weight: 998,
  eat1: () => {
    return "吃东西"
  }
}


@Entry
@Component
struct Index {
  // 定义变量
  @State message: string = 'Hello World';

  // 生命周期

  // 页面入口 （绘制页面）
  build() {
    // build 只能有一个根节点 (容器组件)
    // 概念
    //   容器组件: 线性布局容器(行row, 列Column),  相对布局容器,  flex布局容器,  堆叠布局的容器...
    //   基础组件: 文本, 按钮, 图片, 输入框, 单选复选框......


    // 线性布局 - 列 (根节点)
    Column() {
      // 线性布局 - 行 (容器组件)
      Row() {
        Text("把大象放进冰箱一共分为3步")
        Button("打开冰箱")
        Button("放进去")
        Button("关上冰箱门")
      }

      // 线性布局 - 列 (容器组件)
      Column() {
        Text("把大象放进冰箱一共分为3步")
        Button("打开冰箱")
        Button("放进去")
        Button("关上冰箱门")
      }

      // 常用的 基础组件
      // 线
      Divider()
        .height(2)
        .backgroundColor(Color.Red)

      // 文本组件
      Text("文本内容")

      // 按钮组件
      Button("按钮文本").onClick((event: ClickEvent) => {
      })

      // 图片组件
      Image($r("app.media.startIcon"))
        .width("60vp")

      // 文本输入框
      TextInput({ placeholder: "请输入内容", text: "广州白云" })

      // 搜索框
      Search({ placeholder: "请输入搜索关键字" })
    }

  }
}