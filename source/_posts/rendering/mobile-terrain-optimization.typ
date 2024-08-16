#import "../typst-inc/blog-inc.typc": * 

#show: blog_setting.with(
  title: "移动端地形渲染优化",
  author: ("Leptus He"),
  paper: "jis-b0",
  //preview: true
)

#metadata("渲染技术") <tags>
#metadata("图形渲染") <categories>
#metadata("2024-07-17") <date>

游戏场景地形通常需要在不同地表效果间过渡，地形渲染系统一般使用#im[Texture Splatting]技术来实现该效果。例如，Unity引擎支持在地形区域的每个位置使用4张纹理进行权重混合，形成过渡效果。4张纹理的混合权重存储在一张称为#im[Splat Texture]的纹理中。Splat Texture会覆盖整个地形区域，RGBA四个通道分别存储四个地表纹理图层的混合权重。在运行时，shader会通过fragment的世界位置采样Splat Texture，从而获得4层地表纹理图层的混合权重，然后混合得到最终的地表纹理效果。

Unity的Texture Splatting技术能够得到较好的过渡效果。但是，该技术在移动端存在较大的性能问题。在Shader中，该技术需要采样Splat Texture，以及4个地表纹理图层，共计需要5次纹理采样。如果渲染系统采用了PBR渲染技术，则还需要材质贴图，法线贴图等数据。纹理采样数可高达$13$次($4 times 3 + 1$)。显然，对于移动端而言，该技术的性能开销过大。同时，该技术限制了整个地表区域最终只能够使用4种地表纹理，会导致地形整体的多样性以及丰富度不够。

在项目中，美术要求整个地形区域能够使用大概8张不同的地表纹理。同时，该技术方案也要满足移动端的性能要求。因此，基于Texture Splatting的方案并不适用于项目。为了解决该问题，我们需要设计一种新的技术方案来满足项目的要求。

= 技术方案

在移动端，地形渲染的瓶颈在于纹理采样数过多。因此，为了优化性能，我们需要减少渲染时的纹理采样数量。基于对美术场景的观察，我们可以发现：#im[美术场景地形的大部分区域基本都仅仅只使用到了一层的地表纹理，只有少部分过渡区域才会使用到多层纹理混合。例如，草地与泥地的过渡区域。] 

基于该观察，我们可以执行以下优化：
- 对地表区域进行分割，分割出使用单层纹理的地表区域以及使用多层纹理的地表区域
- 对于单层地表纹理区域，在Shader中采样一层地表纹理
- 对于多层地表纹理区域，依然在Shader中采样多层地表纹理

上述方案能够有效地减少整个地形区域渲染时的纹理采样数量。其具体的优化的性能取决于使用单层纹理区域的比例。

同时，为了能够让美术在整个地形区域使用大于4张的地表纹理。我们采用了纹理数组的方式来组织地形纹理数据，在Shader中通过地表纹理层的id即可采样特定的地表纹理层。理论上，该技术方案可以支持的地表纹理层数由硬件限制，但是应该远远大于8张。

= 单层纹理地形

分割地表区域后，我们会得到大量使用单层纹理的地表网格三角形。那么如何确定这些三角形使用哪个地表纹理图层呢？

一种方式是，我们可以将使用相同地表纹理的三角形网格聚类，形成单独的地表网格，并将图层id存储在材质中。但是，这会产生最多4个网格，绘制时会产生4个draw call。如果地表分为多个chunk，则每个chunk都会产生4个draw call，导致地形draw call数量最多增加为原来的4倍。另外一种方式是将每个三角形使用的地表纹理图层id存储在三角形顶点数据上。该方式虽然会增加顶点数据，但是会减少draw call。最终，项目中考虑使用第二种方法更好。

下一步需要考虑的问题是：如何将三角形使用的地表纹理图层id编码存储在顶点数据上，并在shader中解码以进行纹理采样。

对于地表网格上的三角形，我们可以考虑将地表图层id存储在顶点颜色通道上。顶点颜色通道的格式为uint8，可以存储255个地表纹理图层id。同时，我们可以考虑使用纹理数组来存储地表图层纹理，因此在整个地形中，理论上我们可以最多使用255个地表纹理图层，也能够极大地提升地表效果的丰富度和多样性。

对于地表图层id，我们可以在三角形的三个顶点颜色上都存储该图层id。设该图层id为$k$，则三个顶点颜色值都为$(k, 0, 0)$。在经过渲染管线光栅化后，该三角形产生的fragment所得到的插值颜色值为：

$
c &= alpha dot.c R + beta dot.c G + gamma dot.c B \
&= alpha dot.c (k, 0, 0) + beta dot.c (k, 0, 0) + gamma dot.c (k, 0, 0) \
&= (alpha + beta + gamma) dot.c (k, 0, 0) \
&= (k, 0, 0)
$ <eq-color-rasterization>

由于光栅化时，重心坐标$alpha, beta, gamma$的和为$1$。因此，@eq-color-rasterization 中光栅化插值得到的顶点属性值即为该三角形所使用的图层id。

= 多层纹理地形

== 纹理图层id的存储与编码

当地形网格的三角形需要使用多层地表纹理时，出于性能以及内存的考虑，我们依然将地表纹理图层的id存储在三角形颜色顶点数据中。

虽然单个顶点颜色可以存储4个uint8数据，三个顶点总共能够存储12个uint8数据。但是出于性能考虑，我们限制每个三角形最多使用三个地表纹理图层。
现在我们需要考虑如何将三个地表纹理图层id编码存储到顶点颜色数据中，并且在运行时解码获得。

#let fv = (k) => {$bold(#k)$}

假设三个顶点存储的数据分别用向量值函数$fv(f)(i, j, k)$，$fv(g)(i, j, k)$, $fv(h)(i, j, k)$表示，其中$i, j, k$为需要编码的三个地表纹理图层id。因此，在经过光栅化插值后，fragment得到的顶点属性数据为：

$
fv(p) = fv(f)(i, j, k) dot.c alpha + fv(g)(i, j, k) dot.c beta + fv(h)(i, j, k) dot.c gamma
$ <eq-fv-layer>
其中$alpha, beta, gamma$为该fragment的重心坐标。
对于@eq-fv-layer 而言，$alpha, beta, gamma$以及$fv(p)$是已知的，函数$fv(f), fv(g), fv(h)$是编码函数，也是已知的，目标在于解码得到$i, j, k$的值。

基于线性空间的概念，我们可以考虑以下的编码函数：
$
cases(
  fv(f)(i, j, k) = i dot.c fv(e_1) = i dot.c (1, 0, 0),
  fv(g)(i, j, k) = i dot.c fv(e_2) = i dot.c (0, 1, 0),
  fv(h)(i, j, k) = i dot.c fv(e_3) = i dot.c (0, 0, 1),
)
$
其中$fv(e_1), fv(e_2), fv(e_3)$为三维空间的基向量。

因此，@eq-fv-layer 可以转换为：

$
fv(p) = i dot.c alpha dot.c fv(e_1) + j dot.c beta dot.c fv(e_2) + k dot.c gamma dot.c fv(e_3)
$

因此，地表纹理图层id可以求解为：

$
cases(
  i = (angle.l fv(p), fv(e_1) angle.r) / alpha,
  j = (angle.l fv(p), fv(e_2) angle.r) / beta,
  k = (angle.l fv(p), fv(e_3) angle.r) / gamma,
)
$

上述解码方案要求在fragment shader中获得fragment生成时所使用的重心坐标，但是DirectX中直到Shader Model 6.1才支持在fragment shader获取重心坐标，移动端无法使用。在移动端，一种简单获得重心坐标的的方式是：设置三角形三个顶点的顶点属性值分别为三维空间基向量$fv(e_1), fv(e_2), fv(e_3)$，则插值得到的属性值即为$(alpha, beta, gamma)$。

== 多层纹理混合权重

对于使用多层纹理的三角形而言，其混合的纹理权重直接使用重心坐标来进行插值混合，而无需使用Splat Texture来控制。虽然效果上可能有差异，但是影响不大，也能够正常产生过渡效果。


= References
1. #link("https://en.wikipedia.org/wiki/Texture_splatting")[Texture Splatting - Wiki]
2. #link("https://github.com/microsoft/DirectXShaderCompiler/wiki/SV_Barycentrics")[DirectX Documentation - SV_Barycentrics]