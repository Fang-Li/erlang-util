个人代码工具库: 一刀
======================

[![](https://avatars1.githubusercontent.com/u/16438074?s=400&u=a292238f2a02f58d5c6d8ad7a981757bdfd4a4d0&v=4  "I like erlang ~_~")](http://www.jianshu.com/u/7d378de6edfe)



Key Features
-------------

- **平台环境**  
  - 支持Linux,Mac,Windows多平台编译运行
  - live.sh 互动模式启动
  - start.sh 后台模式启动
  - werl.bat windows启动脚本
  
- **编译规则**
  - erlang原生Emakefile编译规则
  - *nix,Mac平台,make编译
  - windows平台,打开werl.bat快捷方式会自动编译且运行
  - reload模块会保证有更新时自动加载

- **关联启动**
  - 启动时会自动加载所有模块，这样可以关联tab键,快速调试代码  
  - 启动时自动启动.erlang中关于环境的加载
  - 启动时会调用相关的关联beam
  - user_default模块中会加载一些常用shell命令


How to use
-------------

```
git clone git@github.com:Fang-Li/erlang-util.git
cd erlang_util
make clean && make && ./live.sh
```

项目名称由来
-------------

拟取名为工具集或者工具库`kit` `lib`等, 过于单调普通  
定位为一个小而全的日常使用工具库  
想到了瑞士军刀`Swiss Army Knife`, 过长了

命名的用途无外乎解决一下问题:

* 命名空间冲突
* 搜索空间冲突
* 域名是否可用

常见功能的模块名的时候,防止名称冲突,可以节省更多的脑力;  
搜索的时候,可以精准命中,减少干扰;   
所以最终命名为`eknife` : `erlang army knife` `erlang knife`  `一刀`
