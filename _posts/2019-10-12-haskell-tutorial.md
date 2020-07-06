---
layout: post
title: Haskell学习
date: 2019-10-12 10:15:08 +0000
category:
  - Haskell
tags: 
  - Haskell
comment: false
reward: false
excerpt: Haskell学习
---

[haskell官网](https://www.haskell.org/)  
[haskell wiki](https://wiki.haskell.org/)

- [官网的tutorial](#官网的tutorial)
  - [step1 help](#step1-help)
  - [step2 Music is Math](#step2-music-is-math)
  - [step3 Your first Haskell expression](#step3-your-first-haskell-expression)
  - [step4 Types of values](#step4-types-of-values)
  - [step5 Lesson 1 done already](#step5-lesson-1-done-already)
  - [step6 We put the funk in function](#step6-we-put-the-funk-in-function)
  - [step7 Tuples, because sometimes one value ain't enough](#step7-tuples-because-sometimes-one-value-aint-enough)
  - [step8 We'll keep them safe, don't worry about it](#step8-well-keep-them-safe-dont-worry-about-it)
  - [step9 Lesson 2 done! Wow, great job](#step9-lesson-2-done-wow-great-job)
  - [step10 Let them eat cake](#step10-let-them-eat-cake)
  - [step11 Basics over, let's go](#step11-basics-over-lets-go)
  - [step12 You constructed a list](#step12-you-constructed-a-list)
  - [step13 You're on fire](#step13-youre-on-fire)
  - [step14 Lesson 3 over! Syntactic sugar is sweet](#step14-lesson-3-over-syntactic-sugar-is-sweet)
  - [step15 Functions, functors, functoids, funky](#step15-functions-functors-functoids-funky)
  - [step16 Lists and Tuples](#step16-lists-and-tuples)
  - [step17 Let there be functions](#step17-let-there-be-functions)
  - [step18 Let there be functions](#step18-let-there-be-functions)
  - [step19 Exercise time](#step19-exercise-time)
  - [step20 Lesson 4 complete](#step20-lesson-4-complete)
  - [step21 And therefore, patterns emerge in nature](#step21-and-therefore-patterns-emerge-in-nature)
  - [step22 Ignoring values](#step22-ignoring-values)
  - [step23 Exercise](#step23-exercise)
  - [step24 Well done](#step24-well-done)
  - [step25 And that's the end of that chapter](#step25-and-thats-the-end-of-that-chapter)

## 官网的tutorial

### step1 help

`23 * 36` or `reverse "hello"` or `foldr (:) [] [1,2,3]` or `do line <- getLine; putStrLn line` or `readFile "/welcome"`

`foldr`和`do line`的操作理解不能

### step2 Music is Math

type in: `5 + 7`  
got: `12:: Num a => a`

### step3 Your first Haskell expression

type in: `"chris"`  
got: `"chris":: [Char]`

### step4 Types of values

type in: `[42,13,22]`  
got: `[42,13,22]:: Num t => [t]`

### step5 Lesson 1 done already

Let's see what you've learned so far:

1. How to write maths and lists of things.

type in: `sort [42,13,22]`  
got: `[13,22,42]:: (Num a, Ord a) => [a]`

### step6 We put the funk in function

type in: `sort "chris"`  
got: `"chirs":: [Char]`

### step7 Tuples, because sometimes one value ain't enough

type in: `(28,"chirs")`  
got: `(28,"chirs"):: Num t => (t, [Char])`

### step8 We'll keep them safe, don't worry about it

type in: `(1,"hats",23/35)`  
got: `(1,"hats",0.6571428571428571):: (Fractional t1, Num t) => (t, [Char], t1)`

type in: `("Shaggy","Daphnie","Velma")`  
got: `("Shaggy","Daphnie","Velma"):: ([Char], [Char], [Char])`

type in: `fst (28,"chirs")`  
got: `28:: Num a => a`

### step9 Lesson 2 done! Wow, great job

Time to take a rest and see what you learned:

1. Functions can be used on lists of any type.
2. We can stuff values into tuples.
3. Getting the values back from tuples is easy.

type in: `let x = 4 in x * x`  
got: `16:: Num a => a`

### step10 Let them eat cake

ps: Let them eat cake. 习语：何不食肉糜。

`let var = expression in body`  
声明变量并赋值，声明变量 x 并赋值 4，然后通过body运算后再赋值 4 * 4。
>You just bound a variable. That is, you bound x to the expression 4, and then you can write x in some code (the body) and it will mean the same as if you'd written 4.

type in: `let x = 8 * 10 in x + x`  
got: `160:: Num a => a`

type in: `let villain = (28,"chirs") in fst villain`  
got: `28`

### step11 Basics over, let's go

使用`(:)`函数构造了list  
type in: `'a' : []`  
got: `"a" :: [Char]`

### step12 You constructed a list

type in: `['a','b']`  
got: `"ab":: [Char]`

type in: `'a' : 'b' : [] == ['a','b']`  
got: `True:: Bool`

### step13 You're on fire

type in: `['a','b','c'] == "abc"`  
got: `True:: Bool`

字符串`"abc"` 是`['a','b','c']`，可以通过语法糖`'a' : 'b' : 'c' : []`构造。  
type in: `'a' : 'b' : 'c' : []  == "abc"`  
got: `True:: Bool`

### step14 Lesson 3 over! Syntactic sugar is sweet

Let's have a gander at what you learned:

1. In 'a' : [], : is really just another function, just clever looking.
2. Pretty functions like this are written like (:) when you talk about them.
3. A list of characters ['a','b'] can just be written "ab". Much easier!

有点像MapReduce，把(+1)方法传给map方法（
passed the (+1) function to the map function）。

type in: `map (+1) [1..5]`  
got: `[2,3,4,5,6]:: (Enum b, Num b) => [b]`

type in: `map (*99) [1..10]`  
got: `[99,198,297,396,495,594,693,792,891,990]:: (Enum b, Num b) => [b]`

type in: `map (/5) [13,24,52,42]`  
got: `[2.6,4.8,10.4,8.4]:: Fractional b => [b]`

type in: `filter (>5) [62,3,25,7,1,9]`  
got: `[62,25,7,9]:: (Num a, Ord a) => [a]`

### step15 Functions, functors, functoids, funky

tuple可以存放不同类型的元素，list不能

type in: `(1,"George")`  
got: `(1,"George"):: Num t => (t, [Char])`

### step16 Lists and Tuples

list join操作后是新元素放在首位。

type in: `1 : [2,3]`  
got: `[1,2,3]:: Num a => [a]`

type in: `5 : [2,3]`  
got: `[5,2,3]:: Num a => [a]`

tuple 没有类似操作

type in: `let square x = x * x in square 52`  
got: `2704:: Num a => a`

### step17 Let there be functions

`let square x = x * x in square 52`。我这么理解的，这行代码定义了一个函数，函数名是`square`，`x`是入参，函数的操作是`x * x`，随后进行了`square 52`的操作。

type in: `let square x = x * x in map square [1..10]`  
got: `[1,4,9,16,25,36,49,64,81,100]:: (Enum b, Num b) => [b]`

type in: `let add1 x = x + 1 in add1 5`  
got: `6:: Num a => a`

`fst`是一个，`snd`是第二。

type in: `let second x = snd x in second (3,4)`  
got: `4:: Num b => b`

### step18 Let there be functions

type in: `let add1 x = x + 1 in map add1 [1,5,7]`  
got: `[2,6,8]:: Num b => [b]`

type in: `let take5s = filter (==5) in take5s [1,5,2,5,3,5]`  
got: `[5,5,5]:: (Eq a, Num a) => [a]`

type in: `let take5s = filter (==5) in map take5s [[1,5],[5],[1,1]]`  
got: `[[5],[5],[]]:: (Eq a, Num a) => [[a]]`

type in: `toUpper 'a'`  
got: `'A':: Char`

### step19 Exercise time

exercise: "Chris" to upper case

type in: `map toUpper "Chris"`  
got: `"CHRIS":: [Char]`

### step20 Lesson 4 complete

Let's go over what you've learned in this lesson:

1. Functions like `map` take other functions as parameters.
2. Functions like `(+1)`, `(>5)` and `square` can be passed to other functions.
3. Defining functions is just a case of writing what to do with the parameters.

type in: `let (a,b) = (10,12) in a * 2`  
got: `20:: Num a => a`

### step21 And therefore, patterns emerge in nature

type in: `let (a:b:c:[]) = "xyz" in a`  
got: `'x':: Char`

### step22 Ignoring values

golang也有类似的写法

type in: `let (a:_:_:_) = "xyz" in a`  
got: `'x':: Char`

In fact, `(a:b:c:d)` is short-hand for `(a:(b:(c:d)))`, so you can just ignore the rest in one go: `let (a:_) = "xyz" in a`

### step23 Exercise

Try to get the 'a' value from this value using pattern matching: `(10,"abc")`

type in: `let (_, (a:_)) =(10,"abc") in a`  
got: `'a':: Char`

### step24 Well done

type in: `let _:_:c:_ = "abcd" in c`  
got: `'c':: Char`

type in: `let [a,b,c] = "cat" in (a,b,c)`  
got: `('c','a','t'):: (Char, Char, Char)`

type in: `let abc@(a,b,c) = (10,20,30) in (abc,a,b,c)`  
got: `((10,20,30),10,20,30):: (Num t, Num t1, Num t2) => ((t, t1, t2), t, t1, t2)`

### step25 And that's the end of that chapter

help end.
