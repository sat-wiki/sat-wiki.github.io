---
title: "站点迁到 Hugo 与 Blowfish"
date: 2026-11-12
categories: ["本站"]
tags: ["Hugo", "Blowfish", "站点维护"]
summary: "sat-wiki.github.io 从零散静态页面改为 Hugo 构建，源码与站点产物分离，旧链接保持不变。"
---

sat-wiki.github.io 此前只有零散的手写页面：`/chunqiu/` 是一页交互脚本，`/tools/` 下放 TLE 解析器，仓库根目录没有首页，直接访问域名得到的是 404。这次把整站换成 Hugo 构建，主题用 Blowfish，新闻稿与技术文章从此有统一的列表、分类与 RSS。

改动要点：

1. **源码与产物分离**。Hugo 工程放在 `src/`，构建结果发布在仓库根目录，Pages 仍然按传统方式读取根目录，不需要改仓库设置。
2. **旧地址全部保留**。`/chunqiu/`、`/tools/tle_data_analyzer.html` 连同字体文件一起移进 `src/static/`，构建后输出路径与原来一致，外部已有的链接不会失效。
3. **内容分两类**。`/news/` 收新闻稿，按日期倒序；`/tech/` 收技术长文，支持目录、公式、代码与系列归档，两者都进 RSS。
4. **构建依赖固定**。Blowfish v3 要求 Hugo Extended 0.162 以上，本机用 0.169 构建；主题以 git submodule 引入，升级只改 submodule 指针。

后续维护流程：改 `src/content/` 下的 Markdown，跑一次 `./deploy.ps1` 生成并推送。
