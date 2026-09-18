#import "/typ/templates/blog.typ" as upstream
#import "@preview/shiroa:0.2.3": plain-text

#let blog-tags = (
  fourier-transform: "傅里叶变换",
  mathematics: "数学",
  rendering: "图形渲染",
  rendering-technique: "渲染技术",
  spherical-harmonics: "球谐函数",
  temporal-antialiasing: "Temporal Antialiasing",
  dependency-injection: "依赖注入",
  unit-testing: "单元测试",
  typst: "Typst",
  misc: "其他",
)

#let article(
  title: "Untitled",
  desc: [This is a blog post.],
  date: "1970-01-01",
  tags: (),
  draft: false,
  lang: "zh",
  region: "cn",
  body,
) = {
  [#metadata((
    title: plain-text(title),
    author: "Leptus He",
    description: plain-text(desc),
    date: date,
    tags: tags,
    draft: draft,
    lang: lang,
    region: region,
  )) <frontmatter>]

  upstream.main.with(
    title: title,
    desc: desc,
    date: date,
    tags: tags,
    lang: lang,
    region: region,
  )(body)
}

#let main = article
#let main-zh = article
#let main-en = article.with(lang: "en", region: none)
#let code-image = upstream.code-image
