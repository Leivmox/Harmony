//数据持久化存储
// 用户首选项为应用提供Key-Value键值型的数据处理能力，支持应用持久化轻量级数据，并对其修改和查询。
// 数据存储采用键值对形式，键为字符串类型，值可为数字、字符、布尔类型及其对应的数组。
// 用户首选项的持久化文件存储在preferencesDir路径下，创建preferences对象前，需要保证preferencesDir路径可读写。持久化文件存储路径中的加密等级会影响文件的可读写状态，路径访问限制详见应用文件目录与应用文件路径。

//导入 用户首选项 模块
import { preferences } from '@kit.ArkData'
//应用上下文
let context = getContext(this);
//实例对象的配置
let option: preferences.Options = { name: "myStorage" }
// preferences.getPreferencesSync(应用上下文，实例对象的配置)，获取preferences 实例对象
let dataPreferences: preferences.Preferences = preferences.getPreferencesSync(context, option)


//获取本地存储数据
function getStorage(key: string): preferences.ValueType | undefined{
  //从缓存的Preferences实例中获取键对应的值，如果值为null或者非默认值类型，返回默认数据defValue
  return dataPreferences.getSync("key", "")
}

//添加 或 修改 本地存储数据
function saveStorage(key: string, value: preferences.ValueType) {
  //将数据写入缓存的Preferences实例中，可通过flush将缓存的Preferences实例中的数据存储到用户首选项的持久化文件中
  dataPreferences.putSync(key, value);
  dataPreferences.flushSync();
}

//删除单个本地存储数据
function delStorage(key: string) {
  // 从缓存的Preferences实例中删除名为给定Key的存储键值对，可通过flush将Preferences实例持久化，此为同步接口。
  dataPreferences.deleteSync(key);
  dataPreferences.flushSync()
}

//清除所有本地存储数据
function clearStorage() {
  // 清除缓存的Preferences实例中的所有数据，可通过flush将Preferences实例持久化，此为同步接口。
  dataPreferences.clearSync();
  dataPreferences.flushSync()
}

//到处四个模块
export { getStorage, saveStorage, delStorage, clearStorage }