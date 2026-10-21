# 我的第一个 App

这是一个轻量的可安装网页应用（PWA），通过 GitHub Pages 发布。

## 发布

GitHub Actions 会在推送到 `main` 分支时自动部署。首次使用时，如果部署没有启动，请打开仓库 **Settings → Pages**，将 **Build and deployment → Source** 设为 **GitHub Actions**。

## 安装到手机

- **iPhone / iPad：** 用 Safari 打开发布网址，点“分享”，选择“添加到主屏幕”。
- **Android：** 用 Chrome 打开发布网址，在菜单中选择“安装应用”或“添加到主屏幕”。

首次打开需要联网；Service Worker 会缓存基本页面，之后可尝试离线打开。

## 后续迭代

修改 `index.html` 等文件并提交到 `main`，GitHub Actions 会重新发布。