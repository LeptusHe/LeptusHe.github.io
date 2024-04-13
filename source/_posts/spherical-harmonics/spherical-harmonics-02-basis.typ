#import "../typst-template/blog-template.typinc": * 

#show: blog_setting.with(
  title: "球谐函数02 - 基础理论",
  author: ("Leptus He"),
  paper: "jis-b0",
  //preview: true
)

= 球谐函数
球谐函数是定义在球面坐标系上的一组 _基函数_ (basis function)，与傅里叶基函数类似。对于任意的周期函数$f(x)$，傅里叶基函数${1, sin x, cos x, dots, sin (m x), cos( m x), dots }$的线性组合都能够用来对函数$f(x)$进行拟合。类似的，对于定义在球面上的函数$f(theta, phi)$，球谐函数的线性组合可以用来对函数$f(theta, phi)$进行拟合，如 @spherical-harmonics-fitting 所示。

$ f(theta, phi) = sum_(l S 0)^(infinity) sum_(m = -l)^(l) c_l^m S_l^m (theta, phi) $ <spherical-harmonics-fitting>

其中$S_l^m (theta, phi)$为球谐函数，定义如 @spherical-harmonics 所示，其中$l, m in NN$， 且满足$-l <= m <= l$。$P_l^m (x)$为 _伴随勒让德多项式_。

$ cases(S_l^m (theta, phi) = A_l^m P_l^m (cos theta) e^(i m phi),
        A_l^m =  sqrt((2l + 1)/(4 pi) frac((l - m)!, (l+m)!)))
$ <spherical-harmonics>


== 正交性

在球面坐标系上有定义的函数构成函数空间$cal(L)(S)$，而球谐函数$S_l^m (x)$是该函数空间的单位正交基。因此，球谐函数也具有正交性，即

$ integral_(Omega) S_l^m S_(l')^(m') dif omega = delta_(l, l') dot delta_(m, m') $

其中$delta_(k, k')$的定义如下：

$ delta_(k, k') = cases(
  1 quad "if" k = k',
  0 quad "if" k != k' ) $

== 实球谐函数

球谐函数$S_l^m (theta, phi)$是定义在复数域上的函数。但是，许多实际应用（例如计算机图形学）涉及到的是实数域上的球面函数。因此我们需要将复数域上的球谐函数转换为定义在实数域上的球谐函数。
实球谐函数的定义如 @real-spherical-harmonics-transformation 所示：
$ Y_l^m (theta, phi)  = cases(
  1/sqrt(2) (S_l^m (theta, phi) + (-1)^m S_l^(-m) (theta, phi))  quad & "if" m > 0,
  Y_l^0 (theta, phi) quad & "if" m = 0,
  i/sqrt(2) ((-1)^m S_l^m (theta, phi) - S_l^(-m) (theta, phi))  quad & "if" m < 0
) $ <real-spherical-harmonics-transformation>


由于$P_l^m (x)$具有对称性，满足

$ A_l^(-m) P_l^(-m)(cos theta) = (-1)^m A_l^(m) P_l^(m) (cos theta) $ <associated-legendre-symmetry>

带入公式 @associated-legendre-symmetry 到 @real-spherical-harmonics-transformation 中，可以得到

$ Y_l^m (theta, phi)  = cases(
  sqrt(2) Re(S_l^m (theta, phi)) &= sqrt(2) A_l^m P_l^m (cos theta) cos(m phi) quad & "if" m > 0,
  S_l^0 (theta, phi) & = A_l^0 P_l^0 (cos theta) quad & "if" m = 0,
  sqrt(2) Im(S_l^m (theta, phi)) &= sqrt(2) A_l^(-m) P_l^(-m) (cos theta) sin(-m phi)  quad & "if" m < 0
) $ <real-spherical-harmonics>


_为了方便叙述，后续我们提到的球谐函数均指实球谐函数_。

== 球谐函数的性质

为了更加方便地研究球谐函数的性质，我们先使用可视化的方式来绘制球谐函数的三维图像，如 @spherical-harmonics-visualization-plot 所示。 图像对$l in [0, 4]$的球谐函数$Y_l^m (theta, phi)$进行了可视化绘制，其中红色表示正值，绿色表示负值。

#figure(
  image("images/spherical-harmonics-visualization-crop.png", width: 100%),
  caption: [球谐函数可视化]
) <spherical-harmonics-visualization-plot>


当$m = 0$时，从 @real-spherical-harmonics 中可以看出，球谐函数 $Y_l^0 (theta, phi) $只与角度$theta$有关，而与角度$phi$无关。从视觉上看，球谐函数$Y_l^0 (theta, phi)$由无数条和赤道平行的圆形曲线构成，并将单位球体划分为多个区域。如 @zontal-spherical-harmonics-visualization-plot 所示，其函数所构成的三维曲面是旋转曲面。因此，球谐函数$Y_l^0(theta, phi)$也被称为 *带状球谐函数* （zonal spherical harmonics）。

#figure(
  image("images/zontal-sh-label.png", width: 100%),
  caption: [$l in [0, 3]$的带状球谐函数可视化]
) <zontal-spherical-harmonics-visualization-plot>

当$l = abs(m)$时，球谐函数中的勒让德多项式$P_l^(abs(m))(cos theta) = P_l^l (cos theta)$，其中$theta in [0, pi]$，函数如 @sector-spherical-harmonics 所示：

$ P_l^l (cos theta) &= (-1)^l (2 l - 1)!! (1 - cos theta ^2 )^(l / 2) \
                    &= (-1)^l (2l - 1)!!   (sin theta)^l $ <sector-spherical-harmonics>

从公式可以看出，函数$P_l^l (cos theta)$关于$theta = pi$对称，且在$theta = pi$出取得最大或者最小值。我们取$l = 2$，观察其函数图像 @sector-spherical-harmonics-plot，可以看出函数$P_l^l (cos theta)$在$theta = pi$处取得最大值。

#figure(
  image("images/sector-spherical-harmonics-l2.png", width: 60%),
  caption: [函数$P_2^2 (cos theta)$图像]
) <sector-spherical-harmonics-plot>

因此，当$l = abs(m)$时，球谐函数$Y_l^(m)$的表达式如 @sector-spherical-harmonics-expression 所示：

$ Y_l^m (theta, phi) = cases(
  sqrt(2) A_l^(m) P_l^(m) (cos theta) cos(m phi) quad & "if" m = l,
  sqrt(2) A_l^(abs(m)) P_l^(abs(m)) (cos theta) sin(abs(m) phi) quad & "if" m = -l
)  
$ <sector-spherical-harmonics-expression>

因此，当$l = abs(m)$时，球谐函数$Y_l^m (theta, phi)$的函数会由两个互不干扰（正交）的函数部分组成，即伴随勒让德函数部分与正/余弦函数部分，从而使得球谐函数会呈现以下性质，如 @sector-spherical-harmonics-visualization-plot 所示：

#figure(
  image("images/sector-sh-label.png", width: 100%),
  caption: [$l in [0, 4]$的扇状球谐函数可视化]
) <sector-spherical-harmonics-visualization-plot>

- 函数会关于$theta = pi$对称。当角度$phi$固定时，球谐函数在$theta = pi$处取得最大值或者最小值
- 函数在$phi$角度上的函数图像为$cos(m phi)$或者$sin(abs(m) phi)$，因此会呈现多个周期性的正弦或者余弦函数图像，呈现$m$个波峰与波谷，呈现 _扇状结构_。@sector-spherical-harmonics-visualization-plot 中红色为波峰，绿色为波谷

根据以上性质，当$l = abs(m)$的球谐函数$Y_l^m (theta, phi)$也被称为 _扇状球谐函数_（sector spherical harmonics）。

除了带状与扇状球谐函数之外的球谐函数，称为 _tesseral球谐函数_ 。在 @spherical-harmonics-visualization-plot 中，我们可以看到 tesseral球谐函数将整个单位球划分为多个区域（也称为“瓣”）。由于瓣的位置会同时受到角度$theta$与$phi$的影响，因此不呈现带状结构。


== 投影与重构

为了拟合定义在球面上的函数$f(theta, phi)$，我们需要求得该函数在实球谐函数基$Y_l^m (x)$下的线性组合系数$c_l^m$，也称为 _投影系数_。由于球谐函数基是单位正交的，因此我们可以通过 @projection-of-spherical-harmonics 求得投影系数：

$ c_l^m = integral_(Omega) f(theta, phi) Y_l^m (theta, phi) dif omega $ <projection-of-spherical-harmonics>

如果我们已知球谐函数的投影系数$A_l^m$，那么我们也通过公式 @reconstruction-of-spherical-harmonics 重构出函数 $f(theta, phi)$。

$ f(theta, phi) = sum_(l = 0)^(infinity) sum_(m = -l)^(l) c_l^m Y_l^m (theta, phi) $ <reconstruction-of-spherical-harmonics>

= Irradiance Map的计算


$ E(theta, phi) = sum_(l=0)^(infinity) sum_(m=-l)^(l) A_l E_l^m S_l^m $