# Walking in Pixels

Leptus He 的个人技术博客。文章以 Typst 编写，由 Tylant/Astro 生成静态 HTML，并通过 GitHub Actions 部署到 GitHub Pages。

## 快速开始

仓库依赖多个 Git 子模块；请递归克隆：

```bash
git clone --recurse-submodules https://github.com/LeptusHe/LeptusHe.github.io.git
cd LeptusHe.github.io
pnpm install
pnpm dev
```

已有非递归克隆时，补全子模块：

```bash
git submodule update --init --recursive
```

开发服务器默认位于 `http://localhost:4321`。生产构建与本地验收：

```bash
pnpm build
pnpm preview
```

项目固定使用 pnpm 10；Node.js 22 与线上 workflow 一致。

## 目录职责

| 路径 | 职责 |
| --- | --- |
| `content/article/` | 正式文章的 Typst 源文件 |
| `content/other/` | About 等非文章页面的 Typst 源文件 |
| `site/blog.typ` | 文章元数据入口与统一标签定义 |
| `src/` | Astro 路由、页面组件与 Typography 主题样式 |
| `public/` | 发布时原样复制的图片和静态资源 |
| `typ/` | 自有 Typst 模板 fork，用于维护生成规则 |
| `packages/tylant/` | Tylant 上游子模块 |
| `source/` | 旧 Hexo 内容与草稿归档，不是新文章入口 |

## 新增文章

```bash
pnpm create:post -- graphics/taau-resolve "TAAU Resolve 优化"
```

这会创建 `content/article/graphics/taau-resolve.typ`。新文章默认带有 `draft: true`：本地开发可见，生产构建不会发布。完成审阅后改为 `draft: false`。

文章 metadata 示例：

```typst
#import "/site/blog.typ": *

#show: main-zh.with(
  title: "文章标题",
  desc: [一句话说明文章讨论的问题和结论边界。],
  date: "2026-09-18",
  draft: true,
  tags: (
    blog-tags.rendering,
  ),
)
```

统一标签维护在 `site/blog.typ`。新图片放在 `public/images/articles/<slug>/`；已迁移文章的旧图片路径保持不动，以兼容原有链接。

## URL 与迁移兼容

正式文章继续使用原 Hexo 永久链接：

```text
/<year>/<month>/<day>/<article-id>/
```

`/article/<article-id>/` 保留为兼容重定向。已发布文章不要随意修改日期或文件路径。

## 模板与子模块

`typ/` 指向 [LeptusHe/typ](https://github.com/LeptusHe/typ) 的 `leptushe/blog-code-style` 分支。它承载少量站点级生成规则，例如代码行号；普通文章维护不要直接修改该子模块。

需要升级模板时，先比较自有 fork 与上游 [Myriad-Dreamin/typ](https://github.com/Myriad-Dreamin/typ)，在 fork 中处理冲突、构建验证后，再更新博客仓库引用的子模块版本。

## 发布与验收

生产发布只由推送到 `main` 触发：`.github/workflows/gh-pages.yml` 会安装依赖、构建 `dist/` 并部署 GitHub Pages。`migration/tylant` 等非 `main` 分支不会自动发布。

提交文章、模板、路由或元数据前：

1. 运行 `pnpm build`。
2. 用 `pnpm preview` 检查页面。
3. 检查文章正文、图片、公式、代码块、内部链接、永久链接、RSS 与 sitemap。

更完整的日常写作规范见 [AGENTS.md](AGENTS.md)。

## 上游依赖

- [Tylant](https://github.com/Myriad-Dreamin/tylant)
- [Astro](https://astro.build/)
- [Typst](https://typst.app/)
