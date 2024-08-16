#import "../typst-template/blog-template.typc": * 

#show: blog_setting.with(
  title: "傅里叶变换01 - 傅里叶级数",
  author: ("Leptus He"),
  paper: "jis-b0",
  preview: false
)

#metadata("傅里叶变换") <tags>
#metadata("数学") <categories>
#metadata("2024-08-05") <date>

#show: shorthands.with(
  ($<|$, math.angle.l),
  ($|>$, math.angle.r)
)

#set math.equation(numbering: "(1)")


= 傅里叶正交函数集

傅里叶函数集$cal(Phi)$是正交函数集，其中任意两个函数的内积都为0。$cal(Phi)$的定义如@eq-fourier-function 所示。

$
cal(Phi) =  {1, sin(w t), cos(w t), sin (2 w t), cos(2 w t), dots.c, sin(n w t), cos (n w t)}
$ <eq-fourier-function>

傅里叶基函数之间内积的定义如@eq-inner-fourier-basis-func 所示。

$
<|f, g|> = integral_(-T/2)^(T/2) f(x) dot.c g(x) dif x
$ <eq-inner-fourier-basis-func>

#proof[

#im[当正整数$n$与$m$满足]：$n, m > 0$时，

$
<|sin(n w t), sin(m w t)|> &= Integral(-T/2, T/2, sin(n w t) dot.c sin(m w t), dif: t) \
&= cIntegral(1/2 (cos(n - m) w t - cos((n + m) w t))) \
$
分情况讨论，当$m != n$时，根据 @def-integral-of-cos-func 可得：

$
<|sin(n w t), sin(m w t)|> &= 1 /2 dot.c (Integral(-T/2, T/2, cos(n - m) w t, dif: t) - Integral(-T/2, T/2, cos(n+m) w t, dif:t) ) \
&= 1 / 2 dot.c (0 + 0) \
&= 0
$

当$m = n$时，可得：

$
<|sin(n w t), sin(m w t)|> &= 1 /2 dot.c (Integral(-T/2, T/2, cos(n - m) w t, dif: t) - Integral(-T/2, T/2, cos(n+m) w t, dif:t) ) \
&= 1/ 2 dot.c (cIntegral(1) - cIntegral( cos(2 n w t) )) \
&= 1 / 2 dot.c T \
&= T / 2 
$

同理可得：

$
<|cos(n w t), cos(m w t)|> =
cases(
  0\, quad "if " n != m,
  T/2\, quad "if " n = m
)
$

$
<|sin(n w t), cos(m w t)|> &= Integral(-T/2, T/2, 1/2 dot.c (sin(n + m) w t + sin(n - m) w t ), dif: t) \
$

当$n != m$时，由 @def-integral-of-sin-func 可得：

$
<|sin(n w t), cos(m w t)|> = 0
$

当$n = m$时，可得：

$
<|sin(n w t), cos(m w t)|> &= Integral(-T/2, T/2, 1/2 dot.c (sin(n + m) w t + sin(n - m) w t ), dif: t) \
&= cIntegral(1 / 2 sin(2 n w t)) \
&= 0
$

]

= 傅里叶级数

任意一个#im[周期为$T$的函数]都可以展开为不同频率的的正弦与余弦函数的线性组合，即：

$
f(x) = sum_(n=0)^infinity (a_n sin n omega x + b_n cos n omega x)
$ <eq-fourier-series>

对于@eq-fourier-series，我们需要求解系数$a_n$与$b_n$。根据#im[傅里叶正交函数系的性质]可知：

当$n > 0$时，求解系数$a_n$时，可以利用公式：

$
<| f(x), sin(n omega x)|> &= Integral(-T/2, T/2, f(x) dot.c sin n omega x) \
&= cIntegral(sin n omega x dot.c (sum_(n = 0)^infinity (a_n sin n omega x + b_n cos n omega x)) ) \
&= sum_(n=0)^infinity (a_n dot.c cIntegral(sin n omega x dot.c sin n omega x) + b_n cIntegral(sin n omega x dot.c cos n omega x) ) \
&= a_n cIntegral(sin n omega x dot.c sin n omega x) \
&= a_n dot.c T / 2
$

因此，可以得到

$
a_n = 2 / T dot.c <| f(x), sin n omega x |> = 2 / T dot.c integral_(-T/2)^(T/2) f(x) dot.c sin n omega x dif x
$

同理，对于系数$b_n$，可以得到：

$
b_n = 2 / T dot.c <| f(x), cos n omega x |> = 2 / T dot.c integral_(-T/2)^(T/2) f(x) dot.c cos n omega x dif x
$

对于$n = 0$的特殊情况，由于由于当$n = 0$时，
$
cases(
  sin n w t = 0,
  cos n w t = 1
)
$

因此@eq-fourier-series 中的项$a_0 dot.c sin (0 dot.c omega x)$没有意义，系数$a_0$可以为任意值。
对于项$b_0 dot.c cos(0 dot.c omega x)$而言，其值为$1$，则系数$b_0$可以求解。对于系数$b_0$，可以求得：

$
<| f(x), 1 |> &= Integral(-T/2, T/2, f(x) dot.c 1) \
&= cIntegral((sum_(i=0)^infinity (a_n sin n omega x + b_n cos n omega x)) dot.c 1) \
&= sum_(i=0)^(infinity) (a_n dot.c cIntegral(sin n omega x) + b_n dot.c cIntegral(cos n omega x)) quad (1"与" sin n omega x, cos n omega x text("的函数正交性)") \
&= b_0 dot.c cIntegral(cos (0 dot.c omega x)) \
&= b_0 dot.c T
$

因此可得：

$
b_0 = 1/T dot.c <| f(x), 1 |> = 1 / T dot.c integral_(-T/2)^(T/2) f(x) dif x
$

#im[为了后续方便讨论，以及统一形式系数的表述形式]。@eq-fourier-series 中当$n = 0$时的特殊常数项$a_0 sin 0 + b_0 cos 0 = b_0$可以使用单个常数项来表示，即令：

$
c_0 / 2 = a_0 sin 0 + b_0 cos 0 = b_0
$

因此，@eq-fourier-series 可以表述为：

$
f(x) = c_0 / 2 + sum_(i=1)^infinity (a_n dot.c sin n omega x + b_n dot.c cos n omega x)
$ <eq-fourier-series-general>

其中的系数可以使用#im[统一的形式]来表示为：

$
cases(
  c_0 = 2 / T dot.c integral_(-T/2)^(T/2) f(x) dif x,
  a_n = 2 / T dot.c integral_(-T/2)^(T/2) f(x) dot.c sin n omega x dif x,
  b_n = 2 / T dot.c integral_(-T/2)^(T/2) f(x) dot.c cos n omega x dif x,
)
$ <factors-of-fourier-series>


= 复数傅里叶级数

== 复数傅里叶级数推导

傅里叶级数中的每项$a_n sin n omega x + b_n cos n omega x$都同时含有两个基函数$sin n omega x$与$cos n omega x$。#im[为了表达的简单性，我们需要寻找一种方式来将每项中的两个基函数表示为单个基函数。] 利用欧拉公式，我们可以使用复数来同时表示$sin n omega x$与$cos n omega x$函数。

欧拉公式的数学表述为：

$
e^(i x) = cos x + i sin x
$

变形可以得到：

$
e^(-i x) = cos x - i sin x
$

因此，$sin x$与$cos x$可以表示为：

$
cases(
  sin x = (e^(i x) - e^(-i x)) / (2 i),
  cos x = (e^(i x) + e^(- i x)) / 2
)
$

因此，@eq-fourier-series-general 可以表述为：

$
f(x) &= c_0 / 2 + sum_(n=1)^infinity (a_n dot.c (e^(i n w x) - e^(-i n w x)) / (2 i) + b_n dot.c (e^(i n w x) + e^(-i n w x)) / 2) \
&= c_0 / 2 + sum_(n=1)^infinity (a_n dot.c (- i^2) / (2 i)  (e^(i n w x) - e^(-i n w x)) + b_n / 2 dot.c (e^(i n w x) + e^(-i n w x))) \
&= c_0 / 2 + sum_(n=1)^infinity ((- i dot.c a_n) / (2)  (e^(i n w x) - e^(-i n w x)) + b_n / 2 dot.c (e^(i n w x) + e^(-i n w x))) \
&= c_0 / 2 + sum_(n=1)^infinity ((- i dot.c a_n + b_n) / (2) dot.c  e^(i n w x) + (i a_n + b_n) / 2 dot.c e^(-i n w x)) \
&= c_0 / 2 + sum_(n=1)^infinity ((- i dot.c a_n + b_n) / (2) dot.c  e^(i n w x)) + sum_(n=1)^infinity  ((i a_n + b_n) / 2 dot.c e^(-i n w x)) \
&= c_0 / 2 + sum_(n=1)^infinity ((- i dot.c a_n + b_n) / (2) dot.c  e^(i n w x)) + sum_(n=-infinity)^(-1)  ((i a_(-n) + b_(-n)) / 2 dot.c e^(i n w x)) \
$ <eq-complex-form-fourier-series-tmp>

当$n = 0$时，则$e^(i n omega x)$为：
$
e^(i 0 w x) = cos 0 + i sin 0 = 1
$

因此@eq-complex-form-fourier-series-tmp 可以使用复数表示为

$
f(x) = sum_(n = -infinity)^infinity d_n e^(i n omega x)
$

其中$d_n$为：
$
d_n = cases(
  (-i a_n + b_n) / 2 &\, quad n > 0,
  1/2 c_0 &\, quad n = 0,
  (i a_(-n) + b_(-n)) / 2 &\, quad n < 0
)
$

将@factors-of-fourier-series 代入，可以得到：

$
1/2 c_0 &= 1 / 2 dot.c 2 / T Integral(-T/2, T/2, f(x)) \
&= 1 / T cIntegral(f(x) dot.c  e^(-i n 0 x))
$

$
(-i a_n + b_n) / 2 &= 1 / 2 dot.c 2 / T dot.c Integral(-T/2, T/2, f(x) (-i sin n w x + cos n w x)) \
&= 1 / T dot.c cIntegral(f(x) dot.c e^(-i n omega x))
$

$
(i a_(-n) + b_(-n)) / 2 &= 1 / 2 dot.c 2 / T Integral(-T/2, T/2, f(x) (i sin (-n omega x) + cos(-n omega x)))  \
&= 1 / T dot.c cIntegral(f(x) dot.c e^(-i n omega x))
$

因此，参数$d_n$可以统一表述为：

$
d_n = 1 / T Integral(-T/2, T/2, f(x) e^(-i n omega x))
$

#definition("傅里叶级数的复数形式")[
  $
  f(x) &= sum_(n=-infinity)^(infinity) d_n e^(i n omega x) \
  &= sum_(n=-infinity)^(infinity) (1 / T dot.c integral_(-T/2)^(T/2) f(x) dot.c e^(-i n omega x) dif x) dot.c e^(i n omega x)
  $
]

== 复数傅里叶级数的正交函数系

对于周期为$T$的函数$f(x)$，从复数域角度来讲，周期函数$f(x)$可以表示为实变复值函数系$cal(R)$的线性组合，其中函数系$cal(R)$为：

$
cal(R) = { e^(i n omega x)  | n in Z}
$

因此，函数$f(x)$可以表示为：

$
f(x) = sum_(-infinity)^(infinity) d_n dot.c e^(i n omega x)
$

对于函数系$cal(R)$而言，其定义的内积为Hermit内积，如：

$
<| f(x), g(x) |> = 1 / T integral_(-T/2)^(T/2) f(x) dot.c overline(g(x)) dif x
$

事实上，可以证明函数系$cal(R)$是#im[规范正交的]，即：

$
<| e^(i n omega x), e^(i m omega x) |> &= 1 / (T) Integral(-T/2, T/2, e^(i n omega x) dot.c overline(e^(i m omega x)))  \
&= 1 / (T) cIntegral(e^(i n omega x) dot.c e^(-i m omega x)) \
&= 1 / (T) cIntegral(e ^(i (n - m) omega x)) 
$

当$n = m$时，有：
$
<| e^(i n omega x), e^(i m omega x) |> &= 1 / (T) Integral(-T/2, T/2, 1) \
&= 1
$

当$n != m$时，有：
$
<| e^(i n omega x), e^(i m omega x) |> &= 1 / T Integral(-T/2, T/2, e^(i (n - m) omega x)) \
&= 1 / T cIntegral(cos(n - m) omega x + i sin(n - m) omega x) \
&= 1 / T (cIntegral(cos(n - m) omega x) + i cIntegral(sin(n - m) omega x) ) \
&= 0
$

因此，系数$d_n$可以通过hermit内积来进行求解：

$
d_n &= <| f(x), e^(i n omega x) |> \
 &= 1 / T Integral(-T/2, T/2, f(x) dot.c e^(-i n omega x))
$

= 附录

== 三角函数积化和差公式

$
e^(i x) = cos x + i sin x
$ <eq-euler-equation>

因此，可以得到

$
cases(
  sin x = (e^(i x) - e^(- i x)) / (2 i ),
  cos x = (e^(i x) + e^(- i x)) / 2
)
$ <eq-sin-cos-form-of-eulur>

$
cases(
  sin alpha dot.c sin beta = 1/2 (cos (alpha - beta) - cos (alpha + beta)),
  cos alpha dot.c cos beta = 1/2 (cos (alpha - beta) + cos(alpha + beta)),
  sin alpha dot.c cos beta = 1/2 (sin(alpha + beta) + sin(alpha - beta))
)
$

#linebreak()
以$sin alpha dot.c sin beta$为例，使用@eq-euler-equation 进行证明。
#proof[

#let eulur_expr = (a, b, o) => $e^(#a) #o e^(#b)$

将@eq-sin-cos-form-of-eulur 带入 $sin alpha dot.c sin beta$中，得到：
$

sin alpha dot.c sin beta &= (#eulur_expr($i alpha$, $- i alpha$, $-$)) / (2 i) dot.c (#eulur_expr($i beta$, $-i beta$, $-$)) / (2 i) \
&=((e^(i (alpha + beta)) - e^(i (alpha - beta)) ) - (e^(-i (alpha - beta)) - e^(-i (alpha + beta)))) / (-4) \
&= ((e^(i (alpha + beta)) + e^(-i (alpha + beta)) )  - (e^(i (alpha - beta)) + e^(-i (alpha - beta)))) / (-4) \
&= -1/4 (2 dot.c cos(alpha + beta) - 2 dot.c cos(alpha - beta)) \
&= 1/2 (cos(alpha - beta) - cos(alpha + beta))
$

证明完成。
]

== 三角函数的内积


#definition("三角函数的积分")[
  三角函数$sin w t $与$cos w t$在周期$[-T/2, T/2]$内的积分为0，即：

  $
  integral_(-T/2)^(T/2) sin w t dif t = 0 \

  integral_(-T/2)^(T/2) cos w t dif t = 0 \
  $

  其中$w = (2 pi) / T$，$T$为三角函数$sin(w t)$与$cos (w t)$的最小周期。
]

#proof[
  $
  Integral(-T/2, T/2, sin w t, dif: t) &= lr(-1 / w cos w t |)_(-T/2)^(T/2) \
  &= -1/w ( cos ((2 pi) / T dot.c  T / 2) - cos((2 pi) / T dot.c -T / 2 )) \
  &= -1 / w (cos pi - cos(-pi)) \
  &= 0
  $ <def-integral-of-sin-func>

  $
  Integral(-T/2, T/2, cos w t, dif: t) &= lr(1 / w sin w t |)_(-T/2)^(T/2) \
  &= 1/w ( sin ((2 pi) / T dot.c  T / 2) - sin((2 pi) / T dot.c -T / 2 )) \
  &= 1 / w (sin pi - sin(-pi)) \
  &= 0
  $ <def-integral-of-cos-func>
]


#lemma("三角形周期函数的积分")[
  如果三角函数$sin w t$或$cos w t$的最小周期为$T$，其频率$w = (2 pi) / T$，则函数$sin n w t$或者$cos n w t$的在周期$[-T/2, T/2]$上的积分为0，即：

  $
  integral_(-T/2)^(T/2) sin n w t dif t = integral_(-T/2)^(T/2) cos n w t dif t = 0
  $
]

#proof[
  以$sin n w t$为例进行证明，$cos n w t$的情况类似。

  令$w' = n w$，则函数$sin n w t = sin w' t$，则$T' = T / n$，则根据 @def-integral-of-sin-func 以及$sin$函数的周期性，可得：
  $
  integral_(-T/2)^(T/2) sin n w t dif t &= integral_(-n T'/2)^(n T'/2) sin w' t dif t'\
  &= sum_(k = 0)^n integral_(k T' - T'/2)^(k T' + T'/2) sin w' t dif t'\
  &= sum_(k = 0)^n dot.c 0 \
  &= 0
  $
]