#import "../typst-template/blog-template.typc": *

#show: blog_setting.with(
  title: "Temporal Antialiasing - 01",
  author: ("Leptus He"),
  paper: "a1"
)

#metadata("Temporal Antialiasing") <tags>
#metadata("图形渲染") <categories>
#metadata("2019-03-09") <date>

走样问题是渲染领域中经常遇到的一个问题。尤其是近几年，随着PBR(physically based rendering)技术不断地被应用在游戏中，实时渲染中的走样问题就变得严重。在PBR技术被应用以前，走样问题的主要来源是三角形光栅化所生成的锯齿问题，即几何走样问题。然而，在PBR技术被应用后，shading产生的高频的颜色信息成为了走样问题的另一个来源。

对于几何走样问题，实时渲染算法中已经存在的一系列算法，比如MSAA，FXAA等，都能够有效地解决该问题。然而，这些算法对于shading走样问题没有很好的效果。在离线渲染中，super sampling一直都是被普遍应用的一种反走样算法。该算法能够有效地解决几何走样和shading走样问题。然而，由于实时渲染对于算法效率的要求，这导致在实时渲染中应用super sampling算法变得不现实。

Super sampling算法的主要缺点在于该算法的效率不高，如何能够提高super sampling算法的效率成为了一个需要考虑的问题。通常而言，如果需要提高一个算法的效率，人们的主要考虑是否能够利用某些还没有利用的信息来减少算法中的计算量。对于实时渲染而言，一个可以被利用的信息是帧与帧之间的数据的重用。由于实时渲染每秒至少渲染30帧，从而导致帧与帧之间有大部分的像素信息基本是相同的。因此，如何重用这些帧与帧基本相同的像素信息是解决super sampling效率低下的一个方向。

Temporal antialiasing可以说就是在这种思想下出现的一种反走样算法，与其他利用空间信息来进行反走样的算法不同，该算法利用了帧与帧之间的信息来实现反走样。

= 静态场景下的TAA

Super sampling技术通过在一个像素中分布多个样本(sample)的方式来进行反走样，而TAA(Temporal antialiasing)的基本思想是将一个像素中的多个样本分布在多帧中，然后通过将多帧中的样本信息进行加权平均来得到与super sampling相同的效果。

在静态场景下，即场景中的所有物体（几何物体、相机、灯光等）的属性都不变的情况下，TAA能够取得与super sampling相同的效果，而且TAA的效率相比较super sampling而言具有很大的提升。

因为TAA的基本思想是将多个样本分布到多帧中，然后进行加权平均。假设每个像素具有n个样本，则我们需要考虑以下几个问题：

- 如何分布（生成）样本
- 如何为每个样本生成对应的投影矩阵
- 如何对每个样本的采样结果进行加权平均

== 样本的生成

假设我们需要在一个像素中生成n个样本，则样本的分布成为了一个需要考虑的问题。对于该问题，已经存在了许多的解决方法。这里，我们使用Halton低差异序列来生成样本。

== 样本的投影矩阵

如果我们继续采用原来的投影矩阵进行渲染，则我们的样本点是位于像素中心的。如果我们需要使得我们渲染的样本点不位于像素中心，则我们需要为每一个样本生成一个对应的投影矩阵，从而使得该帧的像素中心对应于我们所需要的样本。

为了达到这样的目的，我们需要根据样本点来对投影矩阵进行某些修改。

以OpenGL为例，对OpenGL的投影矩阵的修改如下



```cpp
ProjMatrix[2][0] += (Halton(2, N) *  2.0f – 1.0f ) / WindowWidth;
ProjMatrix[2][1] += (Halton(3, N) * -2.0f + 1.0f ) / WindowHeight;
```

== 样本结果的加权平均

当获得了每个样本的结果以后，我们需要考虑如何对这些样本结果($X_i$)进行加权平均，主要考虑以下两个问题：

- 平均的样本结果数量$N$
- 每个样本的权重$W_i$

一个简单的方法是采用前$N$帧样本结果的平均值来作为当前帧的结果，

$ S_t = 1/N sum_(i=0)^(N-1) X_(t-i) $

如果使用这种方式来对样本进行加权平均，则我们需要在存储前$N$帧的样本结果。然而，这将消耗大量的显存。如果是在非静态场景下，还会存在另一个需要解决的问题——如何寻找在第$t-i$帧中与当前帧(第t帧)的某个像素$P(x_t,y_t)$所对应的像素$P(x_(t-i)^('), y_(t-i)^('))​$。

为了解决需要存储前$N​$帧历史样本的问题，我们可以采用一种称为#im[Exponent Moving Average]的方法。

$ S_t = alpha X_t + (1 - alpha) S_(t-1) $


当$alpha$值很小时，

$ S_t approx 1/N sum_(i=1)^N X_i $

使用Exponent Moving Average方法后，我们不再需要存储前$N$帧的历史样本，而只需存储前一帧的加权平均结果$S_(t-1)$即可。一般而言，$alpha$的值设置为$0.05$。

= 动态场景下的TAA


在静态场景下，不同帧中处于相同位置$(x, y)$处的像素$X_t(x, y)$都是同一个像素中的不同采样点的采样结果，将它们进行加权平均后相当于进行了super sampling。然而，在动态场景（非静态场景）下，当相机运动时，不同帧中同一位置$(x, y)$处的像素$X_t(x, y)$可能不再是同一个像素中的样本点的采样结果。此时，如果将它们的采样结果进行加权平均，则会产生 #im[ghost现象]。

== Motion Vector

假设当前帧为第$t$帧，现在我们需要得到位于位置$(x, y)$处的加权平均后的结果$S(x_t, y_t)$，由于

$
S_t(x, y)= alpha X_t(x, y) + (1 - alpha)S_(t-1)(x^', y^')
$

则我们需要找到存储在history buffer $S_{t-1}$中$(x^', y^')$位置的像素点$S_(t-1)(x^', y^')$。

为了寻找对应的像素位置$(x^', y^')​$，我们只需要将当前帧中处于位置$(x, y)​$处的像素的世界坐标$ "pos"(x, y)​$投影到上一帧中即可获得对应的坐标$(x^', y^')​$，公式如下：

$
(x^', y^') = "Proj"_(t-1) times "View"_(t-1) times "Pos"_w  (x, y)​
$

为了获取与像素$S_t(x, y)$相对应的像素$S_(t-1)(x^', y^')​$，在GBuffer Pass中，我们可以将两个像素位置之间的差值存储到一个运动向量(motion vector)缓存中。

$
arrow(Delta(x, y)) = arrow((x, y)) - arrow((x^', y^'))
$

通过运动向量缓存，我们可以直接获取到与像素$S_t (x, y)$相对应的像素$S_(t-1)(x^', y^')$，然后即可将它们加权获得最终的结果$S_t (x, y)$。

== 几何物体边缘的Motion Vector

当相机运动或者场景中的物体运动时，场景中物体的边缘会失去反走样效果。其原因在于物体边缘的pixel丢失了history color。我们通过对一种简单的情形进行分析，来对物体边缘pixel丢失history color的情况进行说明。

#figure(
  grid(columns: 2, row-gutter: 2mm, column-gutter: 1mm,
  image("./images/motion-vector-before.png"),
  image("./images/motion-vector-after.png"),
  "a) previous frame",
  "b) current frame"),
  caption: "物体边缘的pixel"
) <fig-pixel-history>


如 @fig-pixel-history 所示，蓝色表示物体，白色表背景颜色。每个小矩形代表一个pixel，其中含有四个sample。包围在圆中的sample为当前帧所采样的sample。图a)为前一帧的情况，图b)为当前帧的情况。物体相对于前一帧而言向右运动了一段距离。

在当前帧中，对图b)中被标记为红色的sample进行分析。该sample所属的pixel位于物体的左边缘，且该红色的sample没有被物体边缘覆盖，所以该sample的motion vector为背景的motion vector。假设背景没有运动，则该motion vector为0，从而导致该sample的history color为图1中的绿色sample的颜色，即背景颜色。则在当前帧中，该pixel的颜色为背景颜色。然而，在当前帧中，如果我们需要物体边缘的pixel具有反走样的效果，其history color应该使用图a)中的红色sample位置的历史颜色。通过将图a)中的红色sample位置的历史颜色和图b)中红色sample的当前颜色进行blending后才能够得到反走样效果。

#figure(
  image("./images/motion-vector-pattern.png", width: 70%),
  caption: "dilate pattern"
) <fig:dilate-pattern>

为了解决在运动状态下，物体边缘的pixel失去反走样效果的问题。一般而言，对于每个像素，在计算该像素的motion vector时，我们使用该像素邻域范围中深度最小的那个pixel的motion vector作为该pixel的motion vector。如 @fig:dilate-pattern 所示，当前pixel为图片中心的黑色pixel，我们使用中心的pixel和其邻域中的其他四个黑色pixel的深度进行比较，得到一个最小的深度，该具有最小深度的pixel的motion vector则为中心pixel的motion vector。该方法的主要目的在于，对于某些被多个物体（前景和背景）覆盖的pixel，使用前景的motion vector作为该pixel的motion vector，从而避免出现上述物体边缘的pixel丢失反走样效果的现象。

= References


1. #link("http://advances.realtimerendering.com/s2014/")[High-Quality Temporal Super Sampling[Siggraph 2014]]
2. #link("https://bartwronski.com/2014/03/15/temporal-supersampling-and-antialiasing/")[Temporal Super Sampling and Antialiasing[2014]]
3. #link("http://twvideo01.ubm-us.net/o1/vault/gdc2016/Presentations/Pedersen_LasseJonFuglsang_TemporalReprojectionAntiAliasing.pdf")[Temporal Reprojection Anti-Aliasing in INSIDE[GDC][2016]]
4. #link("https://developer.download.nvidia.com/gameworks/events/GDC2016/msalvi_temporal_supersampling.pdf")[An Excursion in Temporal Super Sampling[GDC][2016]]
5. #link("http://hhoppe.com/supersample.pdf")[Amortized Super Sampling[Siggraph Asia 2009]]