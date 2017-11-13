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


