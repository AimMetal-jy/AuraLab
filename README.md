# 文枢工坊 AuraLab

有语料就能用的学习助手

A learning assistant ready to use with any corpus

## 前端：Flutter
### 结构介绍

- `lib/`: 存放所有Dart源代码。
  - `main.dart`: 应用的入口文件。
  - `models/`: 存放数据模型类。
    - `user_model.dart`: 用户数据模型。
    - `voice_model.dart`: 语音数据模型。
  - `routes/`: 存放路由配置。
    - `app_routes.dart`: 定义应用的路由表。
  - `screens/`: 存放各个页面的UI代码。
    - `audio/`: 音频相关页面，如音频选择和处理。
    - `documents/`: 文档处理页面。
    - `drawer/`: 应用的侧边抽屉菜单。
    - `menu/`: 其他菜单相关页面。
    - `notes/`: 笔记相关页面。
    - `search/`: 搜索功能页面。
    - `settings/`: 设置页面。
    - `translate/`: 翻译功能页面。
    - `user/`: 用户个人中心页面。
    - `vocabulary/`: 词汇表页面。
  - `services/`: 存放业务逻辑服务。
    - `audio_service.dart`: 处理音频相关的业务逻辑。
    - `login_service.dart`: 处理登录相关的业务逻辑。
    - `user_service.dart`: 处理用户相关的业务逻辑。
  - `util/`: 存放通用工具和辅助类。
    - `buttons/`: 自定义按钮组件。
    - `widgets/`: 通用的小组件。
  - `widgets/`: 存放可复用的UI组件。
    - `tab_page_scaffold.dart`: 带标签页的页面脚手架。

## 后端：Go+Python

## 登录注册系统使用到的后端仓库链接:

https://github.com/AimMetal-jy/login_sys_go
