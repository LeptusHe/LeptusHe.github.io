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

## 新增文章

```bash
pnpm create:post graphics/taau-resolve "TAAU Resolve 优化"
```

这会创建 `content/article/graphics/taau-resolve.typ`。新文章默认带有 `draft: true`：本地开发可见，生产构建不会发布。明确确认发布后再改为 `draft: false`。脚本自动填写当天 UTC 日期，发布前需核对预期发布日期。

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

例如，图片文件 `public/images/articles/graphics/taau-resolve/overview.png` 在 Typst 中引用为 `/public/images/articles/graphics/taau-resolve/overview.png`。分类目前由 `src/lib/posts.ts` 的 `categoryTags` 从标签中识别，新增分类时需同步登记。

## 使用 AI 写作

采用“AI 起草、验证并提交工作分支；作者确认后发布”的方式。AI 的详细操作约定见 [AGENTS.md](AGENTS.md)。

1. 提供选题、目标读者、希望解释的问题，以及论文、笔记、代码或实验结果。AI 根据资料组织文章；无法核实的事实应标明待核实，不能编造引用或实验数据。
2. AI 创建 `draft: true` 的 Typst 文章，使用现有模板与标签，补充公式、代码及有来源的图片。日常文章工作在独立工作分支进行。
3. 运行 `pnpm dev`，在终端显示的本地地址审阅全文与排版。草稿只在开发预览可见，`pnpm preview` 展示的是生产构建，不包含草稿。AI 可提交已完成的草稿修改到本地工作分支；推送需明确指示。
4. 修改完善后，明确告诉 AI“发布这篇文章”。AI 核对日期和路径，改为 `draft: false`，构建、测试并检查最终页面、RSS 与 sitemap，再执行下述发布流程。
5. GitHub Actions 部署成功后，检查线上文章地址、正文、图片与公式，才算完成发布。

可以这样开始：“基于这些资料写一篇关于 TAAU 的中文技术文章，面向有渲染基础的读者，创建 Typst 草稿并启动本地预览。”审阅后再说：“发布这篇 TAAU 文章。”

草稿标记仅控制生产文章是否输出；仓库中的草稿源码和 `public/` 中的素材不因此变成私密内容。

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

推送到 `main` 会触发 `.github/workflows/gh-pages.yml`，安装依赖、构建 `dist/` 并部署 GitHub Pages。普通工作分支不会因推送自动发布；workflow 另有手动触发入口，也应视为发布操作。

提交文章、模板、路由或元数据前：

1. 运行 `pnpm build`，然后运行 `pnpm test:typst-html` 和 `pnpm test:interface`；两项测试读取构建产物，因此必须先构建。
2. 用 `pnpm preview` 检查准备发布的文章正文、图片、公式、代码块、内部链接、永久链接、canonical、RSS 与 sitemap。既有文章回归测试通过不能替代对新文章的检查。
3. 发布获得明确授权后，获取远端最新提交，把文章工作分支 rebase 到 `origin/main`，解决冲突并重新验证。检查相对 `origin/main` 的完整变更，确保只包含此次准备发布的内容。
4. 使用 fast-forward 方式更新 `main` 并正常推送，不创建 merge commit，不强制推送 `main`。若远端又有更新，重新 fetch、rebase 和验证。
5. 确认 GitHub Actions 部署成功，并检查线上文章。若失败，报告失败阶段，不把“推送成功”当作“发布成功”。

日常文章从最新 `main` 创建工作分支，例如 `post/taau-resolve`。迁移前的旧版保存在 `legacy/hexo-before-tylant-2026-09-19` 标签中，需要继续维护旧版时可用 `git switch -c legacy/hexo legacy/hexo-before-tylant-2026-09-19` 创建分支。

更完整的日常写作规范见 [AGENTS.md](AGENTS.md)。

## 上游依赖

- [Tylant](https://github.com/Myriad-Dreamin/tylant)
- [Astro](https://astro.build/)
- [Typst](https://typst.app/)
