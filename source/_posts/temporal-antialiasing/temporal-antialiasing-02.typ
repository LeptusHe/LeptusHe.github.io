#import "../typst-inc/blog-inc.typc": *

#show: blog_setting.with(
  title: "Temporal Antialiasing - 02",
  author: ("Leptus He"),
  paper: "a1"
)

#metadata("Temporal Antialiasing") <tags>
#metadata("图形渲染") <categories>
#metadata("2019-03-11") <date>

= History Color失效的情况

当物体运动或者相机运动时，我们需要通过reprojection操作来获得某个pixel在前一帧中的屏幕空间位置，然后从该位置获取history color。然而，并不是在任何情况下，history color都是正确的。


== 相机/物体运动导致的history color失效

如 @fig:occlusion-history-color 所示，当相机在场景中运动时，当前帧中，某个pixel对应的场景采样点为红色点，为了得到该采样点的history color，我们使用上一帧的MVP矩阵来将 该红色采样点投影到屏幕空间中后，然而，history buffer中该屏幕空间位置中存储的history color为绿色采样点的history color，然而我们需要的是红色采样点的history color，从而导致我们获得了一个invalid的history color。

#figure(
  image("./images/occlusion-history-color.png", width: 80%),
  caption: "被遮挡的fragment"
) <fig:occlusion-history-color>

上述情况产生的根本原因在于某些fragment在当前帧可见，然而在上一帧不可见。导致该情况的原因可能是相机的运动或者物体的运动。例如，当相机运动速度较快时，屏幕边缘处的fragment就会在上一帧中不可见，从而导致history buffer中没有存储这些fragment的history color。

== Shading导致的history color失效

当物体或者相机运动时，可能会导致当前帧中的某个fragment的history color没有被存储在history buffer中，从而导致获得的history color是无效的。

然而，即使我们能够在history buffer中获取到某个fragment对应的history color，该history color依然可能无效。假设在上一帧中某个fragment被一个红色的光源照亮，然而在当前帧中该光源颜色变为绿色，从而会导致该fragment的颜色由于shading的变化而不同。最终导致，上一帧的history color不可用，即history color无效。

导致shading的变化原因有很多，例如：
- 光照环境的改变(光源颜色变化、光源开关等)
- 阴影的变化（是否处于阴影中）
- 半透明物体的影响

任何会对导致pixel的颜色产生变化的因素都可能会导致history color变得无效。

= History Color失效后的处理

当history color失效后，我们需要对这种情况进行相应的处理。一种处理方法是丢弃history color，然后直接使用当前帧的颜色作为最终的颜色。然而，该方法会导致pixel失去反走样效果。

另一种处理方式是使用neighborhood clamping方法来进行处理。该方法的基本思想是通过当前帧pixel的一个邻域范围内的像素，来在颜色空间中构造一个颜色范围，然后将history color的大小限制在该范围之中。该方法的基本的假设是——某个pixel反走样后的颜色基本与该pixel邻域范围内pixel颜色的blending结果相同。如果该假设成立，则将history color限制在邻域pixel构成的颜色范围中是一种正确的做法。然而，当pixel中存在sub-pixel feature时，该假设无法成立。

Neighborhood Clamping方法中首先需要根据pixel的邻域颜色来构建一个颜色空间范围，如果我们使用凸包来构造一个颜色空间范围，则我们可以获得一个最小的颜色空间范围。然而，该方法过于复杂，容易造成效率问题。

另一种构造颜色范围的方法是使用axis-aligned bounding box(AABB)。通过使用pixel的邻域颜色来构建一个AABB，则可以构造出一个较紧的颜色范围。并且，我们可以将pixel的颜色从RGB颜色空间转换到YCoCg空间后，再在YCoCg颜色空间构造一个AABB。这是因为YCoCg颜色空间能够体现颜色的亮度差异。

当history color不在AABB范围中时，一种处理方式是将history color进行clamping，即

```cpp
historyColor = clamp(historyColor, minColor, maxColor);
```

另一种处理方式是使用cliping操作，即计算pixel和history color所连接形成的线段与AABB的交点。相比较于clamping操作而言，cliping得到的颜色是pixel和history color的一个插值，与pixel的颜色更相似。

= Flicking问题

在使用neighborhood clamp方法后，场景中可能会有pixel的闪烁问题。即使当相机与物体静止，pixel的闪烁问题依然可能存在。导致闪烁发生的主要原因在于，场景中存在sub-pixel feature，从而导致neighborhood clamp方法的基本假设无法成立。举一个例子来对该情况进行说明。

#figure(
  image("./images/flicking.png", width: 100%),
  caption: "flicking例子"
) <fig:flicking>


如@fig:flicking 所示，previous frame的pixel的颜色为红色$(1,0,0)$，并且其邻域颜色构成的AABB中的$"minColor" = (1,0,0)$，$"maxColor"=(1,1,1)$。假设previous frame的历史颜色为红色$(1,0,0)$，则经过neighborhood clamp操作处理后，history color依然为红色，则最终的结果为红色$(1,0,0)$。在current frame时，由于sample的变化，导致当前的pixel颜色变为白色$(1,1,1)$，并且邻域颜色构成的AABB中的$"minColor"=(1,1,1)$，$"maxColor"=(1,1,1)$，经过neighborhood clamp操作处理后history color变为白色$(1,1,1)$，则最终经过blending后的颜色为白色$(1,1,1)$。通过上面简单的例子可以看出，当场景中存在sub-pixel feature时，即使在静态场景下，像素颜色也会存在帧间变化从而导致闪烁问题的发生。


= 模糊问题

Temporal Antialiasing算法存在的另一个问题是模糊问题。当使用了TAA算法后，渲染出来的图片可能会存在一些模糊。导致该问题的原因主要有以下三个：

- 使用了错误的mipmap level
- reprojection diffusion
- 对无效的history color进行blending

由于mipmap level与图片的分辨率有关，且temporal antialiasing算法在每一帧中采样pixel中的一个sample，从而导致在计算mipmap level时使用的分辨率是屏幕的分辨率。然而，由于temporal antialiasing算法与super sampling算法类似，实际上在计算mipmap level时应该使用super sampling的分辨率，从而导致mipmap的level计算错误。Mipmal level的计算错误可以通过对计算得到的mipmap level增加一个bias来解决。

Reprojection diffusion问题的产生是由于对history buffer进行重采样从而导致的。在对history buffer进行重采样时，采样的位置可能并不在history buffer中的像素中心位置，从而导致采样得到的颜色是对history buffer重构的结果，即是插值出来。该插值出来的像素由于不是一个正确的像素颜色，而是插值出来的，则该插值出来的history color则带有一些模糊的效果，从而会导致blending了该history color的pixel具有模糊效果。并且，由于history buffer是不断累积的，会更加剧这个问题。解决该问题的一个方法是使用更好的重构方法来代替线性插值方法，来使得插值出来的pixel更加锐利。例如，使用Catmull-Rom插值方法来进行插值。

与混合了插值出来的history color类似的原因。当history color无效时，最终的pixel由于混合了无效的history color，也会导致blending后的pixel带有模糊的效果。

另外，为了减轻TAA导致的模糊问题，我们可以通过为当前帧得到的颜色纹理增加一个sharepen filter来减轻该问题。


= References

1. #link("http://advances.realtimerendering.com/s2014/")[High-Quality Temporal Super Sampling[Siggraph 2014]]

2. #link("https://bartwronski.com/2014/03/15/temporal-supersampling-and-antialiasing/")[Temporal Super Sampling and Antialiasing[2014]]

3. #link("http://twvideo01.ubm-us.net/o1/vault/gdc2016/Presentations/Pedersen_LasseJonFuglsang_TemporalReprojectionAntiAliasing.pdf")[Temporal Reprojection Anti-Aliasing in INSIDE[GDC][2016]]

4. #link("https://developer.download.nvidia.com/gameworks/events/GDC2016/msalvi_temporal_supersampling.pdf")[An Excursion in Temporal Super Sampling[GDC][2016]]

5. #link("http://hhoppe.com/supersample.pdf")[Amortized Super Sampling[Siggraph Asia 2009]]