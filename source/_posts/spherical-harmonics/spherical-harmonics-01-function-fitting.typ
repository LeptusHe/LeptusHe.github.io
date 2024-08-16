#import "../typst-template/blog-template.typc": * 

#show: blog_setting.with(
  title: "球谐函数01 - 函数拟合",
  author: ("Leptus He"),
  paper: "jis-b0",
  //preview: true
)

#metadata("球谐函数") <tags>
#metadata("图形渲染;数学") <categories>
#metadata("2023-07-04") <date>

= 函数拟合

计算机应用常常需要使用简单函数的线性组合来拟合某个复杂函数。例如，在游戏开发中，为了实现某些渲染效果，通常会在shader中使用到正弦函数。但是，由于GPU计算正弦函数的指令数较多，性能开销比较高，开发者通常会考虑使用多项式函数$x^n$的线性组合来拟合正弦函数，从而减少计算指令数，提高渲染性能。

假设我们需要计算正弦函数$f(x) = sin(x)$在区间$[-pi, pi]$上的值。为了减少性能开销，
我们考虑使用多项式函数$x^n$的线性组合来逼近函数$sin(x)$，如@approxsin 所示。

$ tilde(f)(x) = sum_(i=0)^n c_i x^i $ <approxsin>

线性组合系数$c_i$的取值应该使得函数$f(x)$与$tilde(f)(x)$之间的误差最小。因此，我们先定义误差函数$g(x)$，然后求得误差函数$g(x)$的最小值点，即可以得到线性组合系数$c_i$。

$ g(x) = integral_(-pi)^(pi) (f(x) - tilde(f)(x))^2 $

由于函数$g(x)$的最小值点必定在极小值点取得，因此求函数$g(x)$的最小值点的一种方法是，求$g(x)$的导数为0的点。另外，我们还可以使用其他方法来求解系数$c_i$，该方法称为 _最小二乘投影_，这是后面重点介绍的方法。

对于函数$sin(x)$，我们可以使用多项式函数$P_i (x)$的线性组合来拟合，其中$P_i (x)$的定义如公式所示。

$ cases(
  P_0(x) = 1 / sqrt(2 pi),
  P_1(x) = (sqrt(3/2)x) / pi^(3/2),
  P_2(x) = (3 sqrt(5/2) (x^2 - pi^2 / 3)) / (2 pi^(5/2)),
  P_3(x) = (5 sqrt(7/2) (x^3 - (3 pi^2 x) / 5)) / (2 pi^(7/2)),
  dots.v
) $

所有在区间$[-pi, pi]$上有定义的一元连续函数能够构成函数空间$L(R)$，而函数$P_i (x)$是该函数空间中的 _基函数_。这意味着函数空间$L(R)$中的任意函数，都可以使用基函数$P_i (x)$的线性组合来表示，即

$ sin(x) = sum_(i=0)^(infinity) c_i P_i (x) $

虽然函数$sin(x)$需要使用无穷项基函数$P_i (x)$的线性组合来表示，但是实际上，我们取基函数的前$n$项也能够很好地来拟合函数$sin(x)$。为了方便起见，我们取前$4$项基函数$P_i (x)$的线性组合来进行拟合，可以表示为：

$ sin(x) approx tilde(f)(x) = sum_(i=0)^(3) c_i P_i (x) $ <approx-eq>

另外，由于函数空间的基函数会满足 _正交性质_，则函数$P_i (x)$应该满足性质：

$ integral_(-pi)^(pi) P_i (x) P_j (x) dif x  = delta_(i, j) $

其中$delta_(i, j)$的定义如下：

$ delta_(i, j) = cases(
  1 quad "if " i != j,
  0 quad "if " i eq j) $ 

基于多项式函数$P_i (x)$的正交性，我们可以通过以下公式求得线性组合系数$c_i$：
$ c_i = integral_(-pi)^(pi) sin(x) P_i (x) dif x $ <coefficient>

@coefficient 的证明如下：
$ c_i &= integral_(-pi)^(pi) sin(x) P_i (x) dif x \
      &= integral_(pi)^(pi) (sum_(k = 0)^(infinity) c_k P_k (x)) P_i(x) dif x\
      &= integral_(pi)^(pi) sum_(k = 0)^(infinity) (c_k P_k (x) P_i (x)) dif x \
      &= c_i integral_(pi)^(pi) P_i^2 (x) dif x \
      &= c_i
$

通过 @coefficient ，我们可以得到函数$tilde(f)(x)$中的系数如下：
$ c_0 = 1, c_1 = 0, c_2 = sqrt(6 / pi), c_3 = 0 $

带入到 @approx-eq，可以得到函数$tilde(f)(x)$的公式如下：

$ tilde(f)(x) &= (315 / (2 pi^4)  - 15 / (2 pi^2) ) x + (35 / 2 - 525 / (2 pi^6)) x^3  \
&approx 0.856983 x - 0.0933877 x^3 $


@img-sin-fitting-4 是函数$sin(x)$与$tilde(f)(x)$在区间$[-pi, pi]$的图像，其中黄色曲线为函数$sin(x)$，绿色曲线为函数$tilde(f)(x)$。 可以看到，函数$tilde(f)(x)$能够较好地拟合函数$sin(x)$。

#figure(
  image("images/sin-fitting-4.png", width: 60%),
  caption: [正弦函数拟合 - 4项]
) <img-sin-fitting-4>

事实上，通过增加多项式函数$P_i (x)$的数量，我们可以不断地提高函数$tilde(f)(x)$对函数$f(x)$的拟合程度。当多项式的数量是$6$个时，即函数$tilde(f) (x) = sum_(i=0)^5 c_i P_i (x)$时，函数图像如 @img-sin-fitting-6-term 所示。从图像可以看出，函数$sin(x)$与$tilde(f)(x)$的曲线几乎一致。我们取 @img-sin-fitting-6-term 中的局部区间$[(3 pi)/10, (7 pi)/10]$，如 @img-sin-fitting-6-term-local 所示，可以看到函数$sin(x)$与$tilde(f)(x)$的曲线误差也很小。

#figure(
  image("images/sin-fitting-6.png", width: 60%),
  caption: [正弦函数拟合 - 6项]
) <img-sin-fitting-6-term>

当函数$tilde(f)(x)$中多项式函数$P_i (x)$的项数趋于无穷时，其极限为$sin(x)$，能够完美地拟合函数$sin(x)$。

#figure(
  image("images/sin-fitting-6-local.png", width: 60%),
  caption: [正弦函数拟合(局部) - 6项]
) <img-sin-fitting-6-term-local>