---
layout: post
title: "1903 高级软件工程-作业2"
date: 2019-10-03 14:20:00 +0000
category:
  - study
tags:
  - mse
comment: false
reward: false
excerpt: 2019年03学期，高级软件工程作业2，使用Haskell解决n皇后。
---

- [Haskell皇后布局](#haskell皇后布局)
- [一、安装Haskell](#一安装haskell)
  - [1.1. 下载Haskell](#11-下载haskell)
  - [1.2. 验证安装是否成功](#12-验证安装是否成功)
- [二、实现Haskell皇后布局程序](#二实现haskell皇后布局程序)
  - [2.1. 给出一种8皇后布局](#21-给出一种8皇后布局)
  - [2.2. 枚举所有8皇后布局](#22-枚举所有8皇后布局)
  - [2.3. 枚举所有n皇后布局](#23-枚举所有n皇后布局)

## Haskell皇后布局

1. 安装Haskell
2. 实现Haskell皇后布局程序，三个步骤：
   - 给出一种8皇后布局
   - 枚举所有8皇后布局
   - 枚举所有n皇后布局（1 <= n <= 100）
3. 提交程序和实现报告，报告用pdf格式。

## 一、安装Haskell

### 1.1. 下载Haskell

从[www.haskell.org](https://www.haskell.org/platform)下载包含ghc的安装文件。  
下载与操作系统对应版本的Haskell进行安装，我下载的是Windows操作系统的8.6.5版本的Haskell Platform。

### 1.2. 验证安装是否成功

命令行输入ghci，进入GHCi则表示安装成功，如下：

``` bash
C:\Users\K>ghci
GHCi, version 8.6.5: http://www.haskell.org/ghc/  :? for help
Prelude>
```

## 二、实现Haskell皇后布局程序

Haskell解决八皇后问题的实现，代码参考[图灵社区八皇后问题](https://www.ituring.com.cn/article/273002)

枚举解决8皇后代码如下，保存为`queens.hs`：

``` haskell
import Control.Monad ( foldM )

safe _ [] _ = True
safe x (x1:xs) n = x /= x1 && x /= x1+n && x /= x1-n && safe x xs (n+1)

queensN n = foldM (\xs _ -> [x:xs | x <- [1..n], safe x xs 1]) [] [1..n]
```

上述程序中：

- safe 函数可以判断新的坐标加到列表的最前面之后，和后面每一行的棋子是否冲突，n 的初始值是 1。每次递归时，n 加 1 表示要判断的行数向下移动了 1 行，直到把之前的方案都判断完毕，任意一步不成功，都会返回 False，代表新的坐标 x 和之前的摆放方案冲突。
- queens 函数计算第 m 步所有可能的摆放列表，所以返回值是列表的列表 [[Int]]。第 m 步所有的摆放方案，等同于向第 m-1 步的所有可能性中添加全部可能的横坐标 x。所以，这里使用列表归纳语法，取出之前所有的摆放方案 xs，从 1 到 n 任取一个值作为新坐标 x，经过 safe 函数过滤出不冲突的摆放。
- queensN 函数调用 queens n，递归计算出 n×n 棋盘上全部的可能摆放。

进入`queens.hs`所在目录，使用GHCi来运行`queens.hs`

``` bash
C:\tool\yizhishi.github.io\_posts>ghci
GHCi, version 8.6.5: http://www.haskell.org/ghc/  :? for help
Prelude> :load queens.hs
[1 of 1] Compiling Main             ( queens.hs, interpreted )
Ok, one module loaded.
*Main> mapM_ print $ queensN 8
[4,2,7,3,6,8,5,1]
[5,2,4,7,3,8,6,1]
[3,5,2,8,6,4,7,1]
...
[6,4,7,1,3,5,2,8]
[4,7,5,2,6,1,3,8]
[5,7,2,6,3,1,4,8]
```

输出数组来表示一组皇后布局，数组下标为0的元素对应棋盘上第一行从左边数的皇后安全摆放位置，下标为1的元素对应棋盘上第二行从左边数的皇后安全摆放位置，以此类推。

### 2.1. 给出一种8皇后布局

一种8皇后布局，如：[1,7,4,6,8,2,5,3]。  
![8皇后布局](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p2/queens_8.jpg)

### 2.2. 枚举所有8皇后布局

所有的8皇后布局，共92种解法，如下：

``` bash
[4,2,7,3,6,8,5,1]
[5,2,4,7,3,8,6,1]
[3,5,2,8,6,4,7,1]
[3,6,4,2,8,5,7,1]
[5,7,1,3,8,6,4,2]
[4,6,8,3,1,7,5,2]
[3,6,8,1,4,7,5,2]
[5,3,8,4,7,1,6,2]
[5,7,4,1,3,8,6,2]
[4,1,5,8,6,3,7,2]
[3,6,4,1,8,5,7,2]
[4,7,5,3,1,6,8,2]
[6,4,2,8,5,7,1,3]
[6,4,7,1,8,2,5,3]
[1,7,4,6,8,2,5,3]
[6,8,2,4,1,7,5,3]
[6,2,7,1,4,8,5,3]
[4,7,1,8,5,2,6,3]
[5,8,4,1,7,2,6,3]
[4,8,1,5,7,2,6,3]
[2,7,5,8,1,4,6,3]
[1,7,5,8,2,4,6,3]
[2,5,7,4,1,8,6,3]
[4,2,7,5,1,8,6,3]
[5,7,1,4,2,8,6,3]
[6,4,1,5,8,2,7,3]
[5,1,4,6,8,2,7,3]
[5,2,6,1,7,4,8,3]
[6,3,7,2,8,5,1,4]
[2,7,3,6,8,5,1,4]
[7,3,1,6,8,5,2,4]
[5,1,8,6,3,7,2,4]
[1,5,8,6,3,7,2,4]
[3,6,8,1,5,7,2,4]
[6,3,1,7,5,8,2,4]
[7,5,3,1,6,8,2,4]
[7,3,8,2,5,1,6,4]
[5,3,1,7,2,8,6,4]
[2,5,7,1,3,8,6,4]
[3,6,2,5,8,1,7,4]
[6,1,5,2,8,3,7,4]
[8,3,1,6,2,5,7,4]
[2,8,6,1,3,5,7,4]
[5,7,2,6,3,1,8,4]
[3,6,2,7,5,1,8,4]
[6,2,7,1,3,5,8,4]
[3,7,2,8,6,4,1,5]
[6,3,7,2,4,8,1,5]
[4,2,7,3,6,8,1,5]
[7,1,3,8,6,4,2,5]
[1,6,8,3,7,4,2,5]
[3,8,4,7,1,6,2,5]
[6,3,7,4,1,8,2,5]
[7,4,2,8,6,1,3,5]
[4,6,8,2,7,1,3,5]
[2,6,1,7,4,8,3,5]
[2,4,6,8,3,1,7,5]
[3,6,8,2,4,1,7,5]
[6,3,1,8,4,2,7,5]
[8,4,1,3,6,2,7,5]
[4,8,1,3,6,2,7,5]
[2,6,8,3,1,4,7,5]
[7,2,6,3,1,4,8,5]
[3,6,2,7,1,4,8,5]
[4,7,3,8,2,5,1,6]
[4,8,5,3,1,7,2,6]
[3,5,8,4,1,7,2,6]
[4,2,8,5,7,1,3,6]
[5,7,2,4,8,1,3,6]
[7,4,2,5,8,1,3,6]
[8,2,4,1,7,5,3,6]
[7,2,4,1,8,5,3,6]
[5,1,8,4,2,7,3,6]
[4,1,5,8,2,7,3,6]
[5,2,8,1,4,7,3,6]
[3,7,2,8,5,1,4,6]
[3,1,7,5,8,2,4,6]
[8,2,5,3,1,7,4,6]
[3,5,2,8,1,7,4,6]
[3,5,7,1,4,2,8,6]
[5,2,4,6,8,3,1,7]
[6,3,5,8,1,4,2,7]
[5,8,4,1,3,6,2,7]
[4,2,5,8,6,1,3,7]
[4,6,1,5,2,8,3,7]
[6,3,1,8,5,2,4,7]
[5,3,1,6,8,2,4,7]
[4,2,8,6,1,3,5,7]
[6,3,5,7,1,4,2,8]
[6,4,7,1,3,5,2,8]
[4,7,5,2,6,1,3,8]
[5,7,2,6,3,1,4,8]
```

### 2.3. 枚举所有n皇后布局

n皇后布局，当n=1时，共有1种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 1
[1]
```

n皇后布局，当n=2时，共有0种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 2
*Main>
```

n皇后布局，当n=3时，共有0种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 3
*Main>
```

n皇后布局，当n=4时，共有2种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 4
[3,1,4,2]
[2,4,1,3]
```

n皇后布局，当n=5时，共有10种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 5
[4,2,5,3,1]
[3,5,2,4,1]
[5,3,1,4,2]
[4,1,3,5,2]
[5,2,4,1,3]
[1,4,2,5,3]
[2,5,3,1,4]
[1,3,5,2,4]
[3,1,4,2,5]
[2,4,1,3,5]
```

n皇后布局，当n=6时，共有4种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 6
[5,3,1,6,4,2]
[4,1,5,2,6,3]
[3,6,2,5,1,4]
[2,4,6,1,3,5]
```

n皇后布局，当n=7时，共有40种解法，如下：

``` haskell
*Main> mapM_ print $ queensN 7
[6,4,2,7,5,3,1]
[5,2,6,3,7,4,1]
[4,7,3,6,2,5,1]
[3,5,7,2,4,6,1]
[6,3,5,7,1,4,2]
[7,5,3,1,6,4,2]
[6,3,7,4,1,5,2]
[6,4,7,1,3,5,2]
[6,3,1,4,7,5,2]
[5,1,4,7,3,6,2]
[4,6,1,3,5,7,2]
[4,7,5,2,6,1,3]
[5,7,2,4,6,1,3]
[1,6,4,2,7,5,3]
[7,4,1,5,2,6,3]
[5,1,6,4,2,7,3]
[6,2,5,1,4,7,3]
[5,7,2,6,3,1,4]
[7,3,6,2,5,1,4]
[6,1,3,5,7,2,4]
[2,7,5,3,1,6,4]
[1,5,2,6,3,7,4]
[3,1,6,2,5,7,4]
[2,6,3,7,4,1,5]
[3,7,2,4,6,1,5]
[1,4,7,3,6,2,5]
[7,2,4,6,1,3,5]
[3,1,6,4,2,7,5]
[4,1,3,6,2,7,5]
[4,2,7,5,3,1,6]
[3,7,4,1,5,2,6]
[2,5,7,4,1,3,6]
[2,4,1,7,5,3,6]
[2,5,1,4,7,3,6]
[1,3,5,7,2,4,6]
[2,5,3,1,7,4,6]
[5,3,1,6,4,2,7]
[4,1,5,2,6,3,7]
[3,6,2,5,1,4,7]
[2,4,6,1,3,5,7]
```

n皇后布局，当n=8时，共有92种解法，详见2.1：

n皇后布局，当n=9时，共有352种解法，如下（部分）：

``` haskell
*Main> mapM_ print $ queensN 9
[7,3,1,6,8,5,2,4,9]
[5,1,8,6,3,7,2,4,9]
[5,3,1,7,2,8,6,4,9]
...
[6,3,5,8,1,4,2,7,9]
[4,6,1,5,2,8,3,7,9]
[5,3,1,6,8,2,4,7,9]
*Main> length $ queensN 9
352
```

n皇后布局，当n=10时，共有724种解法，如下（部分）：

``` haskell
*Main> mapM_ print $ queensN 10
[7,3,1,6,8,5,2,4,9]
[5,1,8,6,3,7,2,4,9]
[5,3,1,7,2,8,6,4,9]
...
[6,3,5,8,1,4,2,7,9]
[4,6,1,5,2,8,3,7,9]
[5,3,1,6,8,2,4,7,9]
*Main> length $ queensN 10
724
```

n皇后布局，当n=11时，共有2680种解法，如下（部分）：

``` haskell
*Main> mapM_ print $ queensN 11
[10,8,6,4,2,11,9,7,5,3,1]
[10,5,7,4,11,8,2,9,6,3,1]
[8,5,11,6,10,2,4,9,7,3,1]
...
[4,7,1,6,2,10,8,3,5,9,11]
[2,7,5,8,1,4,10,3,6,9,11]
[2,4,6,8,10,1,3,5,7,9,11]
*Main> length $ queensN 11
2680
```

n值在往上增加，递归时间会变得很长，所以并未一一列举。

附：queens.hs

``` haskell
import Control.Monad ( foldM )

safe _ [] _ = True
safe x (x1:xs) n = x /= x1 && x /= x1+n && x /= x1-n && safe x xs (n+1)

queensN n = foldM (\xs _ -> [x:xs | x <- [1..n], safe x xs 1]) [] [1..n]
```
