#import "../typst-inc/blog-inc.typc": * 

#show: blog_setting.with(
  title: "傅里叶变换02 - 傅里叶变换",
  author: ("Leptus He"),
  paper: "jis-b0",
  preview: false
)

#metadata("傅里叶变换") <tags>
#metadata("数学") <categories>
#metadata("2024-09-21") <date>

#show: shorthands.with(
  ($<|$, math.angle.l),
  ($|>$, math.angle.r)
)

#set math.equation(numbering: "(1)")



= 傅里叶变换

周期为$T$的函数$f(x)$可以用傅里叶级数来表示，但是无法表示#im[非周期函数]。非周期函数可以看做周期$T -> infinity$的周期函数。
当$T -> infinity$时，则
$
omega = (2 pi) / T  -> 0
$

代入傅里叶级数中，得到：

$
f(x) &= sum_(n = -infinity) ^(infinity) d_n dot.c e^(i n omega x) \
&= sum_(n = -infinity)^infinity (1 / T dot.c Integral(-T/2, T/2, f(x) dot.c e^(-i n omega x))) dot.c e^(i n omega x) \
&= sum_(n = -infinity)^infinity (1 / (2 pi) dot.c omega dot.c Integral(-T/2, T/2, f(x) dot.c e^(-i n omega x))) dot.c e^(i n omega x) \
$ <eq-riemann-sum-omega>

基于定积分的概念，@eq-riemann-sum-omega 可以看做对连续变量$omega'$的黎曼和形式。对于连续变量$omega'$，将定义区间分为$m$份小区间，每个区间的长度为$Delta omega$，为微小增量。对于第$n$个区间，选取的变量为$epsilon = n Delta omega$，则@eq-riemann-sum-omega 可以变换为：

$
f(x) &= sum_(n = -infinity) ^(infinity) d_n dot.c e^(i n omega x) \
&= sum_(n = -infinity)^infinity (1 / (2 pi) dot.c Delta omega dot.c Integral(-T/2, T/2, f(x) dot.c e^(-i epsilon x))) dot.c e^(i epsilon x) \
&= sum_(n = -infinity)^infinity ( (1 / (2 pi) dot.c Integral(-T/2, T/2, f(x) dot.c e^(-i epsilon x))) dot.c e^(i epsilon x)) dot.c Delta omega \
&= Integral(-infinity, infinity, 1 / (2 pi) Integral(-infinity, infinity, f(x) dot.c e^(-i omega x)) dot.c e^(i omega x) , dif: omega) \
&= 1 / (2 pi) dot.c Integral(-infinity, infinity, Integral(-infinity, infinity, f(x) dot.c e^(-i omega x)) dot.c e^(i omega x) , dif: omega)
$

令$F(omega)$为：

$
F(omega) = Integral(-infinity, infinity, f(x) dot.c e^(-i omega x))
$

则傅里叶变换公式可以表示为：

$
f(x) = Integral(-infinity, infinity, F(omega) dot.c e^(i omega x), dif: omega)
$

其中$F(omega)$为频率为$omega$时的线性组合系数。

= 离散傅里叶变换

傅里叶变换与傅里叶级数都是对连续信号进行分析处理的工具，而无法对离散的时间信号或者有限长信号进行分析。为了解决傅里叶变换的局限性，
#im[离散傅里叶变换]被提出来对离散时间信号进行频谱分析，例如二维图像、离散采样的信号等。

== 周期离散信号的表示
对于离散信号$x[n]$，如果满足：
$
x[n] = x[n + N]
$
则该信号为一个周期为$N$的信号。其最小正周期为$N$，频率$omega_o = 2 pi \/ N$。

复指数函数$phi.alt[n] = e^(i omega_o n)$也是周期函数，其中$n$为函数自变量。该函数的周期为$N$。并且，@complex-exp-function-set 中的复指数函数都是周期函数，

$
phi.alt_k [n] = e^(i k omega_o n) = e^(i k (2 pi) / N dot.c n),  quad k = plus.minus 0, plus.minus 1, plus.minus 2, dots.c 
$ <complex-exp-function-set>
fuzhishu
其频率都是$omega_o$的倍数。

事实上，@complex-exp-function-set 中只有$N$个函数是不同。因为函数$phi.alt[n]$为周期函数，其周期为$N$，因此：
$
phi.alt_(k + m N) [n] = phi.alt_k [n]
$

#proof[
$
phi.alt_(k + m N) [n] &= e^(i (k + m N) dot.c (2 pi) / N dot.c n) \
&= e^(i (k (2 pi) / N + m dot.c 2 pi) dot.c n) \
&= e^(i k (2 pi) / N dot.c n) dot.c e^(i m 2 pi dot.c n) \
&= e^(i k (2 pi) / N dot.c n) dot.c (cos(m 2 pi n) + i sin (m 2 pi n)) \
&= e^(i k (2 pi) / N dot.c n) dot.c 1 \
&= phi.alt_k [n]
$
]

另外，设函数集合$Phi$定义如下：

$
Phi = { e^(i k omega_o n) | k = 0, 1, 2, dots.c, N - 1 }
$

定义在函数集$Phi$上的内积为：

$
<| f[n], g[n] |> = sum_(k=0)^(N-1) f[n] dot.c overline(g[n])
$
则可以证明：函数集$Phi$是正交函数集。

#proof[
  $
  <| phi.alt_k [n], phi.alt_m [n] |> &= sum_(i=0)^(N-1) e^(i k (2 pi) / N n) dot.c e^(-i m (2 pi) / N n) \
  &=sum_(i = 0)^(N - 1) e^(i (k - m) (2 pi) / N n)
  $

  当$k = m$时，有：
  $
  <| phi.alt_k [n], phi.alt_m [n] |> &=sum_(i = 0)^(N - 1) e^(i (k - m) (2 pi) / N n) \
  &= sum_(i=0)^(N-1) e^(i 2 pi 0) \
  &= sum_(i=0)^(N-1) 1 \
  &= N
  $

  当$k != m$时，设$alpha = e^(i (k - m) (2 pi) / N)$，则有：
  $
  alpha != 1
  $
  根据几何级数公式，有：
  $
  sum_(i=0)^N alpha^n = (1 - a^N) / (1 - a)
  $

  由于
  $
    a^N = (e^(i 2 pi (k - m) / N))^N = e^(i 2 pi (k - m)) = cos((k - m) 2 pi) - i sin((k - m) 2 pi) = 1
  $
  因此可得：
  $
  sum_(i = 0)^N alpha^n = (1 - alpha^N) / (1 - alpha) = 0
  $

  综上所述：

  $
  <| phi.alt_k [n], phi.alt_m [n] |> = cases(
    N &\, quad "if " k = m,
    0 &\, quad "if " k != m
  )
  $
  因此，函数集$Phi$是正交函数集。
]

因此，任意的周期为$N$的离散信号$x[n]$都可以使用正交函数集$Phi$的线性组合来表示，即：

$
x[n] = sum_(k=0)^(N-1) a_k dot.c phi.alt_k [n]
$

其中，系数$a_n$可以用正交函数的性质表示为：

$
a_k &= 1 / N dot.c <|x[n], phi.alt_k [n] |> \
&= 1 / N dot.c sum_(n = 0)^(N-1) (x[n] dot.c e^(i k omega_o n))
$


= 快速傅里叶变换

离散傅里叶变换需要求$N$个线性组合系数$a_k$，而每个系数$a_k$都需要$N$次复数乘法。因此，计算所有$N$个组合系数的算法复杂度为$O(n^2)$。

为了解决计算离散傅里叶系数的算法复杂度过高的问题，快速傅里叶变换被提出了。快速傅里叶变换利用分治的思想，将大规模的DFT(discret fourier transform)问题转换为若干个小规模的DFT问题进行递归求解，其算法复杂度为$O(n log n)$。

== $N$次单位根及其性质

对于复平面上的单位圆，将其$N$等分，得到$N$个等分点的集合，该集合称为#im[$N$次单位根]。其中每个点的相位角相差$(2 pi) / N$弧度。该集合中的根可以表示为：


$
W_N^k  = e^(i (2 pi) / N dot.c k), quad k = 0, 1, dots.c, N- 1
$

#definition([$N$次单位根的性质])[
  对于$N$次单位根，其满足以下性质：
  - 周期性：
  $
  W_N^(k) = W_N^(k + m dot.c N)
  $
  - 对称性：
  $
  W_N^(k + N / 2) = - W_N^(k)
  $
  - 若$m$是$N$的约数，则：
  $
  W_N^(m k) = W_(N/m)^k
  $
]

== 快速傅里叶算法

对于周期为$N$的函数$x[n]$，其线性组合系数为$a_0, a_1, dots.c, a_(N-1)$。
离散傅里叶变换的线性组合系数$a_k$的计算公式如下：

$ a_k &= 1 / N dot.c sum_(n = 0)^(N-1) (x[n] dot.c e^(i k omega_o n)) $

其中：

$
omega_o = (2 pi) / N
$

对该公式中的形式进行简化，令
$
alpha = e^(i k omega_o) = W_N^k,
$

且令函数$f(alpha)$为：
$
f(alpha) &= sum_(n = 0)^(N-1) (x[n] dot.c e^(i k omega_o n)) \
&= sum_(n = 0)^(N-1) (x[n] dot.c alpha^n)
$

=== 分治法

将函数$f(a)$分解为：

$
f(alpha) &= x[0] dot.c alpha^0 + x[1] dot.c alpha^1 + dots.c  + x[N-1] dot.c alpha^(N-1) \
&= (x[0] dot.c alpha^0 + x[2] dot.c alpha^2 + dots.c + x[N-2] dot.c alpha^(N-2)) \
& quad + (x[1] dot.c alpha^1 + x[3] dot.c alpha^3 + dots.c + x[N-1] dot.c alpha^(N-1)) \
&= (x[0] dot.c alpha^0 + x[2] dot.c alpha^2 + dots.c + x[N-2] dot.c alpha^(N-2)) \
& quad + alpha dot.c (x[1] dot.c alpha^0 + x[3] dot.c alpha^2 + dots.c + x[N-1] dot.c alpha^(N-2))
$

令
$
f_1(alpha) &= (x[0] dot.c alpha^0 + x[2] dot.c alpha^1 + dots.c + x[N-2] dot.c alpha^(N/2-1)) \
f_2(alpha) &= (x[1] dot.c alpha^1 + x[3] dot.c alpha^1 + dots.c + x[N-1] dot.c alpha^(N/2-1))
$

则
$
f(alpha) = f_1(alpha^2) + alpha dot.c f_2(alpha^2)
$

根据$N$次方根的性质3，即：

$
W_N^(m k) &= W_(N/m)^k 
$

可以得到：

$
f(alpha) &= f(W_N^k) = f_1(W_N^(2 k)) + alpha dot.c f_2(W_N^(2 k)) \
&= f_1(W_(N/2)^(k)) + alpha dot.c f_2(W_(N/2)^(k)) \
$

函数$f_1(W_(N/2)^k)$展开为：

$
f_1(W_(N/2)^k) = x[0] dot.c W_(N/2)^(k dot.c 0) + x[2] dot.c W_(N/2)^(k dot.c 1) + x[4] dot.c W_(N/2)^(k dot.c 2) + dots.c + x[2 floor(N / 2)] dot.c W_(N/2)^(k dot.c n)
$

对于周期为$N$的信号$x[n]$，将其下标$n$为偶数与奇数的信号元素进行分组，可以得到两个子信号，分别为$x[2 n]$以及x[2 n + 1]，其中$n$满足：
$
n in Z, " 且 "  n <= floor(N /2)
$

因此，$f_1(W_(N/2)^k)$可以看做是对周期为$N/2$的信号$x[2 n]$求取系数$a_k$过程。同理，$f_2(W_(N/2)^k)$可以看为对周期为$N/2$的信号$x[2 n + 1]$求取系数$a_k$的过程。


从上面可以看出，对于周期为$T$的信号$x[n]$，求取其离散傅里叶变换系数${a_k| k = 0, 1, dots.c, N-1}$的过程，可以划分为两个子问题：
- 求子信号$x[2 n]$的离散傅里叶变换系数
- 求子信号$x[2 n + 1]$的离散傅里叶变换系数

该流程一直会递归，则到子信号的周期为$1$，此时可以直接求解。

=== 周期性

当对周期为$T$的信号$x[n]$求离散傅里叶变换的系数时，根据$N$次单位根的对称性，可以发现以下结论：

令$m = k + N/2$，其中$0 <= k < N / 2$。根据$N$次单位根的周期性有：

$
f(W_N^(k + N / 2)) &= f_1(W_N^(2k + N)) + W_N^(k+N/2) dot.c f_2(W_N^(2k+N)) \
&= f_1(W_N^(2k) dot.c W_N^N) + W_N^(k+N/2) dot.c f_2(W_N^(2k) dot.c W_N^N) \
&= f_1(W_N^(2k) dot.c 1) + W_N^(k+N/2) dot.c f_2(W_N^(2k) dot.c 1) \
&= f_1(W_N^(2k)) - W_N^(k) dot.c f_2(W_N^(2k)) \
&= f_1(W_(N/2)^(k)) - W_N^(k) dot.c f_2(W_(N/2)^(k)) \
&= f_1(W_(N/2)^(k)) - alpha dot.c f_2(W_(N/2)^(k)) \
$

因此，当$m > N / 2$时，根据对称性，可以通过子信号$x[2n]$与$x[2 n + 1]$的离散傅里叶变换系数，可以简单的得到离散傅里叶变换中$a_m$的系数值。