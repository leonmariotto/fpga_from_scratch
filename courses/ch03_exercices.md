# Chapter 03 : exercices

## 3.1
![Ex01](./ch03/ex01.svg)

## 3.3
![Ex02](./ch03/ex02.svg)

## 3.5
![Ex02](./ch03/ex05.svg)

## 3.7

It's a SR latch with inverted inputs.

## 3.23

Let's state the following encoding :
| states | encoding |
|--------|----------|
|  st0   |    00    |
|  st1   |    01    |
|  st2   |    10    |

**WARNING: S0 and S1 represent bit 0 and 1 of the state encoding where bit 0 is
the least significant bit.**.
States transition:
| S0 | S1 | A | B | S'0 | S'1 |
|----|----|---|---|-----|-----|
|  0 |  0 | 1 | X |  1  |  0  |
|  0 |  0 | 0 | X |  0  |  0  |
|  1 |  0 | X | 1 |  0  |  0  |
|  1 |  0 | X | 0 |  0  |  1  |
|  0 |  1 | 1 | 1 |  0  |  1  |
|  0 |  1 | 0 | X |  0  |  0  |
|  0 |  1 | X | 0 |  0  |  0  |

Outputs:
| S0 | S1 | A | B | Q |
|----|----|---|---|---|
|  0 |  0 | X | X | 0 |
|  1 |  0 | X | X | 0 |
|  0 |  1 | 1 | 1 | 1 |
|  0 |  1 | X | 0 | 0 |
|  0 |  1 | 0 | X | 0 |

- S'0 = s0s1A
- S'1 = S0s1B + s0S1AB
- Q = s0S1AB

Because the encoding 11 don't exist we can remove s0 when S1 :
- S'0 = s0s1A
- S'1 = S0s1B + S1AB
- Q = S1AB

![Ex23 schematic](./ch03/ex23_schematic.svg)


## 3.25

![Little snail brain](./ch03/little_snail_brain.svg)


## 3.29
## 3.31
## 3.33
## 3.35
