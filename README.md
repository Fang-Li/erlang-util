个人代码工具库
======================

[![](https://avatars1.githubusercontent.com/u/16438074?s=400&u=a292238f2a02f58d5c6d8ad7a981757bdfd4a4d0&v=4  "I like erlang ~_~")](http://www.jianshu.com/u/7d378de6edfe)

windows工作目录编译环境

Key Features
-------------

- **环境**  
  - 适用于windows环境
  - 可以自己修改werl.bat以适用*nix环境
  
- **编译**
  - Emakefile满足该项目可以一键编译所有src下源代码
  - 打开bat快捷方式自动编译一次
  - reload模块会保证有更新时自动加载
  - user_default启动前需要单独编译放在主目录

- **启动**
  - 启动时会自动加载所有模块，这样可以关联tab键
  快速调试代码  
  - 启动时自动启动.erlang中关于环境的加载
  - 启动时会调用相关的关联beam
  - user_default模块中会加载一些常用shell命令


How to use
-------------

```
git clone git@github.com:Fang-Li/erlang-util.git
cd erlang_util
make clean && make && make live
```

要给项目取个名字了
-------------

拟取名为工具集或者工具库`kit` `lib`等  
感觉过于庸俗了  
一个小而全的日常使用工具库  
想到了瑞士军刀`Swiss Army Knife`  
过长  
取名为`army`得了,不够贴切,`knife`太具象的不知所措了  
其实一个名称的用途无外乎一下几种用途
* 命名空间冲突
* 搜索空间冲突
* 域名是否可用

也没想过注册一个域名啥的,完全是自用  
取一些同样功能的,或者常见功能的模块名的时候,防止名称冲突,节省更多的脑力而已  
搜索的时候,不至于搜索出一大批无关紧要的东西来  
总不能大家都叫做`gen_server` `time_util`这些  
又为了区分不同的语言  
所以最终定位`eknife` : `erlang army knife` `erlang knife`  `一刀`
唉!  
爱怎么叫怎么叫吧
