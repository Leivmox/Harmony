// src/main/ets/utils/CityData.ets

export interface CityItem {
  code: string;
  name: string;
  children?: CityItem[];
}

export const CITY_DATA: CityItem[] = [
  {
    "code": "110000",
    "name": "北京市",
    "children": [
      {
        "code": "110100",
        "name": "北京市",
        "children": [
          { "code": "110101", "name": "东城区" },
          { "code": "110102", "name": "西城区" },
          { "code": "110105", "name": "朝阳区" },
          { "code": "110108", "name": "海淀区" }
        ]
      }
    ]
  },
  {
    "code": "310000",
    "name": "上海市",
    "children": [
      {
        "code": "310100",
        "name": "上海市",
        "children": [
          { "code": "310101", "name": "黄浦区" },
          { "code": "310104", "name": "徐汇区" },
          { "code": "310105", "name": "长宁区" },
          { "code": "310106", "name": "静安区" },
          { "code": "310115", "name": "浦东新区" }
        ]
      }
    ]
  },
  {
    "code": "440000",
    "name": "广东省",
    "children": [
      {
        "code": "440100",
        "name": "广州市",
        "children": [
          { "code": "440103", "name": "荔湾区" },
          { "code": "440104", "name": "越秀区" },
          { "code": "440105", "name": "海珠区" },
          { "code": "440106", "name": "天河区" }
        ]
      },
      {
        "code": "440300",
        "name": "深圳市",
        "children": [
          { "code": "440303", "name": "罗湖区" },
          { "code": "440304", "name": "福田区" },
          { "code": "440305", "name": "南山区" },
          { "code": "440306", "name": "宝安区" }
        ]
      }
    ]
  }
]