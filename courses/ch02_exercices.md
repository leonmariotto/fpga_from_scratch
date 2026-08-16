# Chapter 02 : exercices

## 2.1

a)
- Y = ab + aB + AB
- Y = a(b + B) + AB
- Y = a + AB

b)
- Y = abc + ABC

c)
- Y = abc + aBc + Abc + AbC + ABC

d)
- Y = abcd + abcD + abCd + abCD + Abcd + AbCd + ABCd
- Y = abc + abC + Abd + ABCd
- Y = ab + Abd + ABCd

e)
- Y = abcd + abCD + aBcD + aBCd + AbcD + AbCd + ABcd + ABCD
- Y = ab(cd + CD) + BD(ac + AC) + aBCd + AbcD + AbCd + ABcd
- Y = ab + BD + aBCd + AbcD + AbCd + ABcd

## 2.3

a)
- Y = (a + B)

b)
- Y = (a + b + C)(a + B + c)(a + B + C)(A + b + c)(A + b + C)(A + B + c)

c)
- Y = (a + b + C)(a + B + C)(A + B + c)

d)
- Y = (a + B + c + d)(a + B + c + D)(a + B + C + d)(a + B + C + D)(A + b + c + D)(A + b + C + D)(A + B + c + d)(A + B + c + D)(A + B + C + d)

e)
- Y = (a + b + c + D)(a + b + C + d)(a + B + c + d)(a + B + C + D)(A + b + c + d)(A + b + C + D)(A + B + c + D)(A + B + C + d)

## 2.5

a)
- Y = ab + Ab + AB
- Y = ab + A
- Y = b + A

b)
- Y = abc + ABC

c)
- Y = abc + aBc + Abc + AbC + ABC
- Y = ac + Ab + ABC
- Y = ac + A(b + BC) -> factor A
- Y = ac + A(b + C) -> use identity
- Y = ac + Ab + AC -> distribute

d)
- Y = abcd + abcD + abCd + abCD + Abcd + AbCd + ABCd
- Y = abc + abC + Abd + ABCd
- Y = ab + Abd + ABCd
- Y = b(a + Ad) + ABCd
- Y = b(a + d) + ABCd
- Y = ba + bd + ABCd
- Y = ba + d(b + ABC)
- Y = ba + d(b + AC)
- Y = ba + bd + ACd

e)
- Y = abcd + abCD + aBcD + aBCd + AbcD + AbCd + ABcd + ABCD

## 2.7

![Ex07](./ch02/ex_07.png)

## 2.9

With bubble pushing I can replace the NOR gate by NOT and AND gates.

## 2.13

- Y = AC + abC
- Y = C(A + ab)
- Y = C(A + b)
- Y = AC + bC

- Y = ab + aBc + nor(A, c)
- Y = ab + aBc + aC
- Y = ab + a(Bc + C)
- Y = ab + a(B + C)
- Y = ab + aB + aC
- Y = a(b + B) + aC
- Y = a + aC

- Y = abcd + Abc + AbCd + ABD + abCd + BcD + a
- Y = abcd + Abc + bCd(a + A) + ABD + BcD + a
- Y = abcd + Abc + bCd + ABD + BcD + a
- Y = bc(ad + A) + bCd + ABD + BcD + a
- Y = bc(d + A) + bCd + ABD + BcD + a
- Y = bcd + bcA + bCd + ABD + BcD + a
- Y = bd(c + C) + bcA + ABD + BcD + a
- Y = bd + bcA + ABD + BcD + a
- Y = bd + bc + BD + BcD + a
- Y = bd + c(b + BD) + BD + a
- Y = bd + c(b + D) + BD + a
- Y = bd + bc + cD + BD + a -> use *consensus*: cD is already covered by `BD + bc`
- Y = bd + BD + bc + a

## 2.15

![Ex15](./ch02/ex_15.png)

## 2.17
## 2.22
## 2.23
## 2.28
## 2.29
## 2.30
## 2.36
## 2.41
## 2.43
## 2.48
