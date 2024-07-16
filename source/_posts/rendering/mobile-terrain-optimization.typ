#import "../typst-template/blog-template.typinc": * 

#show: blog_setting.with(
  title: "球谐函数02 - 基础理论",
  author: ("Leptus He"),
  paper: "jis-b0",
  preview: true
)

#metadata("球谐函数") <tags>
#metadata("图形渲染;数学") <categories>
#metadata("2023-07-09") <date>

= 移动端地形纹理混合

为了在不同地表效果间进行过渡，地形渲染系统通常都支持使用#im[Texture Splatting]的技术来实现该效果。例如，Unity引擎支持在地形区域的每个位置使用4张纹理来进行权重混合，得到过渡的效果。其中4张纹理的混合权重存储在一张称为#im[Splat Texture]的纹理中。Splat Texture会覆盖整个地形区域，纹理中的RGBA四个通道分别存储四个地表纹理图层的混合权重。在运行时，通过判断fragment的世界位置来采样Splat Texture，即可得到该位置的4层地表纹理图层混合权重，然后进行混合既可得到最终的地表纹理效果。


Unity的Texture Splatting技术能够得到较好的过渡效果。但是，在移动端该技术具有较大的性能问题。在Shader中，该技术需要采样Splat Texture，以及4个地表纹理图层，共计5个纹理采样。如果渲染系统采用了PBR渲染技术，则还需要材质贴图，法线贴图等数据。纹理采样数可高达$13$个($4 times 3 + 1$)。显然，对于移动端而言，该技术的性能开销过大。


在移动端，地形渲染的瓶颈在于采样数过多。因此，为了优化性能，我们需要减少渲染时所需要的纹理采样数。基于对美术场景的观察，我们可以发现：#im[美术场景地形的大部分区域都没有同时使用到4层纹理混合，基本都只使用到了仅仅一层的地表纹理。只有少部分的过渡区域才会使用到多层纹理混合。例如，草地与泥地的过渡区域。] 基于该观察，我们可以执行以下优化：

- 对地表区域进行分割，分割出使用单层纹理的地表区域以及使用多层纹理的地表区域
- 对于使用单层的地表区域，只需要在Shader中采样一层地表纹理图层既可
- 对于使用多层纹理的地表区域，依然在Shader中采样多层地表纹理图层

上述方案能够有效地减少整个地形区域渲染时的纹理采样数目。其具体的优化的性能取决于使用单层纹理图层的区域所占比例。

= 单层纹理地形

在对地表区域进行分割后，我们就能够得到大量使用单层地表纹理图层的地表三角形。那么如何确定该三角形使用4个地表图层中的哪个呢？一种方式是，我们可以考虑将使用相同地表图层的三角形网格聚类，形成单独的地表网格，然后将该图层的id存储在材质中。但是，该方法会在地表区域中产生最多4个网格，绘制时会产生4个draw call。如果地表分为多个chunk，则每个chunk都会产生4个draw call，会导致地形draw call数量最多增加为原来的4倍。另外一种方式是，将每个三角形使用的地形图层id存储在三角形顶点数据上。该方式会增加顶点数据，但是会减少draw call。最终，项目中考虑使用第二种方法更好。

下一步需要考虑的问题是：如何将三角形使用的地形图层id存储在三角形顶点数据上。同时，如何在shader中获取该数据进行纹理采样。

= 多层纹理地形

= References
- #link("https://en.wikipedia.org/wiki/Texture_splatting")[Texture Splatting - Wiki]