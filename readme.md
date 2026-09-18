# Walking in Pixels

Leptus He 的个人技术博客。文章使用 Typst 编写，Tylant/Astro 生成静态 HTML，并由 GitHub Actions 发布到 GitHub Pages。

## 本地使用

```bash
pnpm install
pnpm dev
```

开发服务器默认位于 `http://localhost:4321`。生产构建：

```bash
pnpm build
pnpm preview
```

项目固定使用 pnpm 10；Node.js 22 与线上 workflow 一致。

## 新增文章

```bash
pnpm create:post -- graphics/taau-resolve "TAAU Resolve 优化"
```

这会创建 `content/article/graphics/taau-resolve.typ`。新文章模板默认带有 `draft: true`：本地开发可见，生产构建不会发布。完成审阅后改为 `draft: false`。

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

统一标签维护在 `site/blog.typ`。新图片放在 `public/images/articles/<slug>/`。

## URL 与迁移兼容

正式文章继续使用原 Hexo 永久链接：

```text
/<year>/<month>/<day>/<article-id>/
```

`/article/<article-id>/` 保留为兼容重定向。不要随意修改已发布文章的日期或文件路径。

## 发布

推送到 `main` 后，`.github/workflows/gh-pages.yml` 会安装依赖、构建 `dist/` 并部署 GitHub Pages。首次启用时，需要在仓库 Pages 设置中选择 GitHub Actions 作为发布源。

日常内容规范与验收要求见 `AGENTS.md`。

## 上游依赖

- [Tylant](https://github.com/Myriad-Dreamin/tylant)
- [Astro](https://astro.build/)
- [Typst](https://typst.app/)
