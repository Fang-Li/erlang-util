## 并查集

### 关联模块

* union_find.erl
* friends_circle.erl
* array_lab.erl

### union_find

并查集的数据结构和基础算法


```
union_find:singletons_from_list([1,2,3,4,5..n])
```
生成n个树,每个数的父亲都指向本人  
数的数据结构由ets表示


```
union_find:union(F, a, e)
```
把成员a和e关联到一棵树下



### array_lab

二维数组的实现

```
new(Data)
```
会创建一个以Data为准的多维数组, 行列同Data组成的矩阵的行数和列数


### friends_circle

```
find_circle_num()
```
可以获取班级成员组成的圈子数量