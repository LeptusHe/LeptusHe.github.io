# Typst HTML 语义组件设计

## 目标

在不改变 PDF/SVG 输出外观的前提下，让迁移后博客的 Typst 正文在 HTML 导出时恢复旧主题的关键视觉语义：标题编号、蓝色强调文字，以及带有明确层级的证明与数学环境卡片。

## 背景与边界

`astro-typst` 目前以 HTML 模式编译 Typst。该导出以语义化 HTML 为目标，不能保留 Typst 的画布排版；现有 `set text`、`set heading`、`place` 与 `rect` 等布局规则因此不会完整映射到网页。

本次只处理公共 Typst 定义及其在文章正文中的样式，不重写网站整体主题，也不替换现有 Zebraw 代码块渲染。PDF/SVG 目标继续走原有 Typst 定义，避免影响历史输出与本地预览。

## 架构

公共 Typst 文件依据编译目标分流：

- 非 HTML 目标保留现有的 `set`、`place`、`rect` 等定义。
- HTML 目标使用 `html.elem` 输出带稳定 class 的语义元素，不把颜色、边距等表现细节内联进内容。
- `src/styles/typography.css` 只在 `.post-content` 范围内为这些 class 提供视觉映射，避免污染导航、归档页和普通 Markdown 正文。

这将内容语义留在 Typst 公共模板中，把响应式、颜色与细节尺度留在网页 CSS 中。

## 组件契约

| Typst 语义 | HTML 输出 | 网页呈现 |
| --- | --- | --- |
| `#im[...]` | `span.typst-important` | 与旧主题一致的柔和蓝色、常规字重；不再退化成粗体。 |
| 启用编号的标题 | `h2`–`h6` 内的 `span.typst-heading-number` 与标题正文 | 编号具有低干扰的蓝灰层级，正文标题保持可读、可选中。 |
| `#proof[...]` | `aside.typst-proof`，含标签和正文子元素 | 深色底上的橙色左侧强调，标签为“证明如下：”。 |
| `#definition`、`#theorem` 等数学环境 | `aside.typst-environment` 加环境类型 class，含标签和正文子元素 | 以环境类型对应的低饱和强调色显示；保留原有计数和名称。 |

标题仍使用正确的 HTML heading 标签；证明和数学环境使用 `aside`，从而保留辅助技术可理解的内容边界。所有 class 都以 `typst-` 为前缀。

## 数据流

文章导入 `blog-inc.typc` 与 `common.typc` 后，模板先检测输出目标。HTML 分支产生语义组件，Astro 将其置于 `.post-content`，再由 scoped CSS 完成视觉映射。SVG/PDF 分支不生成这些 HTML 元素，继续使用原有布局型 Typst 内容。

## 降级与兼容性

若某个 Typst 功能不支持 HTML 元素生成，构建必须明确失败，而不能静默回退为粗体或普通段落。每次验证均通过实际 Astro 构建检查；现有文章的链接、目录和纯文本内容不应因标题分支而丢失。

## 验收与测试

新增面向构建产物的 Node 测试，针对傅里叶级数文章确认：

1. 导出的 HTML 包含 `typst-important`，且不依赖 `strong` 承担强调语义。
2. 至少一个启用编号的 Typst 标题包含 `typst-heading-number`。
3. 证明与数学环境导出为带 `typst-proof` / `typst-environment` class 的结构化元素。
4. `pnpm build` 成功，随后运行该测试并检查生成页面。
5. 在本地浏览器中确认文章正文字号、文楷字体、重点色与卡片层级协调；桌面和窄屏均不产生横向溢出。

## 非目标

- 不尝试让 HTML 像 SVG/PDF 一样像素级复现任意 Typst 布局。
- 不修改文章正文源文件来手工补 class。
- 不改变站点外壳的 `LXGW WenKai Screen` 字体策略。
- 不引入新的 CSS 框架或客户端 JavaScript。
