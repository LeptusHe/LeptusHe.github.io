#import "../typst-template/blog-template.typinc": *

#show: blog_setting.with(
  title: "hexo-test",
  author: ("Leptus He", )
)


= Hexo Title <document_title>

测试下

#figure(
      image("../spherical-harmonics/images/sin-fitting-4.png", width: 50%),
      caption: [
            测试图片
      ]
)

有些作者会告诉你应该一完成研究就写摘要。但是，很可能你的项目耗时数月甚至数年，因此，你所完成的研究全貌可能在你脑子里已并不清晰。先写论文可以解决这个问题。在你将你的工作成果的所有方面浓缩到一个文件里时，你的记忆将得到有效的刷新。 文稿可以指导摘要的写作，而摘要是你的研究的精简概括。

如果你无法决定从哪里开始写，就考虑过一遍你的论文并勾出每部分最重要的句子（介绍、方法、结果和讨论/结论）。然后，用这些句子作为提纲来撰写摘要。在这时，了解一下你的目标期刊的风格，研究他们的摘要原则也很重要。比如，有些期刊要求摘要结构清晰，分成不同部分，而且大多数期刊有严格的字数限制。

== Chapter 01

$ S_t = f_t + b_t $

参考 @document_title

摘要的第一部分举足轻重，这 1-3 句话必须让读者知道你为什么进行这项研究。

比如，“等位基因间的上位性效应（即非加和性反应）对于种群健康形成的重要性一直是个争议话题，一部分原因是受到缺乏实验证据的影响。”1 是一个很好的引导性句子。它既陈述了主要议题（上位性效应对于种群健康的作用），也说明了问题（这个领域缺乏实验证据）。这样，读者的注意力被立刻抓住了。下一个句子可以接着讲述这个领域缺乏什么样的信息，或者以前的研究者曾做了哪些努力来解决这个问题。

这样的陈述可以很自然地引出关于你的研究如何能独特地解决这个问题的陈述。使用诸如“这里，我们的目的是......”或“这里，我们证实......”等句子来向读者表明你在陈述你的研究目标或目的。

== Chapter 02

#lorem(100)

$ sum_0^1 i = integral f(x) dif x $

== 测试

#lorem(100)

== 问题

$ c_i &= integral_(-pi)^(pi) sin(x) P_i (x) dif x \
      &= integral_(pi)^(pi) (sum_(k = 0)^(infinity) c_k P_k (x)) P_i(x) dif x\
      &= integral_(pi)^(pi) sum_(k = 0)^(infinity) (c_k P_k (x) P_i (x)) dif x \
      &= c_i integral_(pi)^(pi) P_i^2 (x) dif x \
      &= c_i
$

#lorem(20)