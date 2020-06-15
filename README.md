![logo](https://avatars2.githubusercontent.com/u/14118733?s=400&v=4) Welcome to OregonCore!
=================================================================================

该存储库专用于所有oregoncore模块

Build Status
------------

| Compiler      | Platform    | Branch | Status                  |
|:--------------|:------------|:------:|:-----------------------:|
| clang         | Linux x64   | master | [![Build Status][1]][7] |


如何安装模块
---------------------------
```
1) 只需将模块放在OregonCore源代码的“modules”目录下。 
2) 将SQL手动导入到正确的数据库(auth, world or characters)，或者在配置中使用DB更新器
3) 重新创建build文件并编译
```

为什么某些模块声明azerothcore？
----------------------------------------
一些模块是从3.3.5开始的反向移植，其中一些被反向移植的模块是我已经开发或为azerothcore创建的模块。

我可以在这里发布更多模块吗？
-----------------------------------
是的，任何可以随意发布模块的人只要打开PR，它将被合并。


[1]: https://api.travis-ci.org/talamortis/OregonCore-Modules.svg?branch=master
[2]: https://ci.appveyor.com/api/projects/status/bxn9cq9miqxn33gr/branch/master
[3]: https://wiki.oregon-core.net/
[4]: https://docs.oregon-core.net/
[5]: https://discord.gg/Nyc3fTy
[6]: https://forums.oregon-core.net/
[7]: https://travis-ci.org/github/talamortis/OregonCore-Modules
[8]: https://ci.appveyor.com/project/OregonCore/OregonCore/branch/master
