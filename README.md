# sat-wiki.github.io

SatWiki Research 的站点源码：Hugo + [Blowfish](https://blowfish.page/) 主题，构建产物直接发布在仓库根目录，由 GitHub Pages 以传统方式提供。站点语言为英文（`languages.en.toml`），只有一套语言，不做多语切换。

## 目录

```
src/                 Hugo 工程
  config/_default/   站点与主题配置（hugo.toml / languages.en.toml / params.toml / menus.en.toml）
  content/           Markdown 内容
    news/            新闻稿（按日期倒序）
    space-systems/   技术长文（子系统、轨道、series、公式）
    about/           关于
  layouts/partials/  覆盖主题的局部模板
  static/            直接输出的静态文件：/chunqiu/、/tools/、字体
  themes/blowfish/   git submodule（不要手改）
deploy.ps1           构建 + 清理过期文件 + 提交并推送
```

仓库根目录的 `*.html`、`css/`、`js/`、`news/`、`space-systems/` 等均为构建产物，不要手动编辑；要改内容请改 `src/`。

## 环境要求

- Hugo Extended **0.162 以上**（Blowfish v3 要求），当前用 0.169 构建
- Git（含 submodule 支持）

首次克隆：

```powershell
git clone --recurse-submodules https://github.com/sat-wiki/sat-wiki.github.io.git
```

已克隆但缺主题：

```powershell
git submodule update --init --recursive
```

## 本地预览

```powershell
hugo server -s src -D
```

默认在 http://localhost:1313/。

## 发布

```powershell
.\deploy.ps1 -Message "content: 新增某篇新闻稿"
```

脚本会：构建到 `.build/` → 按 `.publish-manifest.txt` 删除已下线的旧文件 → 复制到仓库根目录 → 写 `.nojekyll` → commit 并 push 到 `main`。GitHub Pages 随后自动刷新，通常 1–3 分钟。

## 写新文章

新闻稿：

```powershell
hugo new content -s src news/my-release/index.md
```

技术文章同理，放在 `src/content/space-systems/<slug>/index.md`，front matter 至少写 `title`、`date`、`summary`、`categories`、`tags`；同一专题多篇用相同的 `series` 值串联。

## 说明

- `src/layouts/partials/` 下有两个覆盖主题的小改动：`cta-button.html` 去掉首页按钮尾部的外链图标，`home/landing.html` 让首页正文左对齐（主题默认在桌面端居中，中文长段落读起来很碎）。改主题其它行为时同样放这里，不要动 `themes/blowfish/`。
- `.nojekyll` 让 Pages 跳过 Jekyll，直接按文件提供 Hugo 产物。
- `src/` 与主题 submodule 也会被 Pages 原样提供（内容与 git 仓库一致），不影响主站；如需彻底隔离，可改用 GitHub Actions 部署。
- 主题配色、首页布局在 `src/config/_default/params.toml` 中调整；首页英雄区文案在 `src/content/_index.md` 的 front matter（`heroCaption`、`heroLead`、`heroButtons`）。
