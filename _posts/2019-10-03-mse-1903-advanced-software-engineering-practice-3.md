---
layout: post
title: "1903 高级软件工程-作业3"
date: 2019-10-03 14:20:00 +0000
category:
  - study
tags:
  - mse
comment: false
reward: false
excerpt: 2019年03学期，高级软件工程作业3，使用TensorFlow识别数字验证码
---

- [使用TensorFlow识别数字验证码的要求](#%e4%bd%bf%e7%94%a8tensorflow%e8%af%86%e5%88%ab%e6%95%b0%e5%ad%97%e9%aa%8c%e8%af%81%e7%a0%81%e7%9a%84%e8%a6%81%e6%b1%82)
- [一、安装Python和TensorFlow](#%e4%b8%80%e5%ae%89%e8%a3%85python%e5%92%8ctensorflow)
  - [1.1. 安装Python](#11-%e5%ae%89%e8%a3%85python)
    - [1.1.1 下载Python](#111-%e4%b8%8b%e8%bd%bdpython)
    - [1.1.2 为Python设置环境变量](#112-%e4%b8%bapython%e8%ae%be%e7%bd%ae%e7%8e%af%e5%a2%83%e5%8f%98%e9%87%8f)
    - [1.1.3 验证是否安装成功](#113-%e9%aa%8c%e8%af%81%e6%98%af%e5%90%a6%e5%ae%89%e8%a3%85%e6%88%90%e5%8a%9f)
  - [1.2. 安装TensorFlow](#12-%e5%ae%89%e8%a3%85tensorflow)
    - [1.2.1 安装TensorFlow](#121-%e5%ae%89%e8%a3%85tensorflow)
    - [1.2.2 验证是否安装成功](#122-%e9%aa%8c%e8%af%81%e6%98%af%e5%90%a6%e5%ae%89%e8%a3%85%e6%88%90%e5%8a%9f)
  - [1.3. 安装其他库](#13-%e5%ae%89%e8%a3%85%e5%85%b6%e4%bb%96%e5%ba%93)
    - [1.3.1 安装imageio和IPython](#131-%e5%ae%89%e8%a3%85imageio%e5%92%8cipython)
    - [1.3.2 验证是否安装成功](#132-%e9%aa%8c%e8%af%81%e6%98%af%e5%90%a6%e5%ae%89%e8%a3%85%e6%88%90%e5%8a%9f)
- [二、复制Mnist（手写数字识别）代码](#%e4%ba%8c%e5%a4%8d%e5%88%b6mnist%e6%89%8b%e5%86%99%e6%95%b0%e5%ad%97%e8%af%86%e5%88%ab%e4%bb%a3%e7%a0%81)
- [三、运行Mnist程序，完成测试，包括系统自带的测试数据和自己手写数字的数据](#%e4%b8%89%e8%bf%90%e8%a1%8cmnist%e7%a8%8b%e5%ba%8f%e5%ae%8c%e6%88%90%e6%b5%8b%e8%af%95%e5%8c%85%e6%8b%ac%e7%b3%bb%e7%bb%9f%e8%87%aa%e5%b8%a6%e7%9a%84%e6%b5%8b%e8%af%95%e6%95%b0%e6%8d%ae%e5%92%8c%e8%87%aa%e5%b7%b1%e6%89%8b%e5%86%99%e6%95%b0%e5%ad%97%e7%9a%84%e6%95%b0%e6%8d%ae)
  - [3.1. 训练模型](#31-%e8%ae%ad%e7%bb%83%e6%a8%a1%e5%9e%8b)
  - [3.2. 准备手写数字](#32-%e5%87%86%e5%a4%87%e6%89%8b%e5%86%99%e6%95%b0%e5%ad%97)
  - [3.3. 验证手写数字](#33-%e9%aa%8c%e8%af%81%e6%89%8b%e5%86%99%e6%95%b0%e5%ad%97)

## 使用TensorFlow识别数字验证码的要求

1. 安装Python和TensorFlow
2. 复制Mnist（手写数字识别）代码
3. 运行Mnist程序，完成测试，包括系统自带的测试数据和自己手写数字的数据
4. 提交程序和实现报告，报告用pdf格式。

## 一、安装Python和TensorFlow

### 1.1. 安装Python

#### 1.1.1 下载Python

从[python官方网站](https://www.python.org/downloads/)下载与电脑操作系统对应的最新版本的Python。  
我下载的是Windows对应的exe文件，运行exe文件安装Python，安装路径为`C:\tool\python3.7.3`。

#### 1.1.2 为Python设置环境变量

将`C:\tool\python3.7.3`和`C:\tool\python3.7.3\Scripts`添加进系统环境变量。

#### 1.1.3 验证是否安装成功

命令行输入`python -V`，如果安装成功会提示安装的python的版本，如：

``` bash
Python 3.7.3
```

### 1.2. 安装TensorFlow

#### 1.2.1 安装TensorFlow

使用pip安装，命令行输入`pip install tensorflow`。

#### 1.2.2 验证是否安装成功

命令行输入`pip show tensorflow`，安装成功会提示TensorFlow的信息，如：

``` bash
Name: tensorflow
Version: 2.0.0
Summary: TensorFlow is an open source machine learning framework for everyone.
Home-page: https://www.tensorflow.org/
Author: Google Inc.
Author-email: packages@tensorflow.org
License: Apache 2.0
Location: c:\tool\python3.7.3\lib\site-packages
Requires: grpcio, wheel, tensorflow-estimator, keras-preprocessing, opt-einsum, absl-py, wrapt, numpy, protobuf, astor, termcolor, six, tensorboard, google-pasta, keras-applications, gast
Required-by:
```

### 1.3. 安装其他库

#### 1.3.1 安装imageio和IPython

使用pip安装，命令行输入`pip install imageio`和`pip install ipython`

#### 1.3.2 验证是否安装成功

命令行输入`pip show imageio`和`pip show ipython`，提示对应信息即表示安装成功。

## 二、复制Mnist（手写数字识别）代码

从[初学者的 TensorFlow 2.0 教程](https://www.tensorflow.org/tutorials/quickstart/beginner)，复制并整理手写数字识别的代码，代码如下：

``` python
from __future__ import absolute_import, division, print_function, unicode_literals
import tensorflow as tf

# 载入并准备好 MNIST 数据集。将样本从整数转换为浮点数：
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

# 将模型的各层堆叠起来，以搭建 tf.keras.Sequential 模型。为训练选择优化器和损失函数：
model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation='softmax')
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# 训练并验证模型：
model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test,  y_test, verbose=2)

# 模型保存
model.save('myminst.model')
```

## 三、运行Mnist程序，完成测试，包括系统自带的测试数据和自己手写数字的数据

### 3.1. 训练模型

运行上述运行代码，执行结果为：

``` bash
Train on 60000 samples
Epoch 1/5
60000/60000 [==============================] - 6s 104us/sample - loss: 0.2971 - accuracy: 0.9142
Epoch 2/5
60000/60000 [==============================] - 6s 96us/sample - loss: 0.1440 - accuracy: 0.9570
Epoch 3/5
60000/60000 [==============================] - 6s 102us/sample - loss: 0.1073 - accuracy: 0.9671
Epoch 4/5
60000/60000 [==============================] - 6s 99us/sample - loss: 0.0887 - accuracy: 0.9727
Epoch 5/5
60000/60000 [==============================] - 8s 138us/sample - loss: 0.0739 - accuracy: 0.9772
10000/1 - 1s - loss: 0.0389 - accuracy: 0.9771
```

现在，这个照片分类器的准确度已经达到**98%**，并且模型已经保存为`myminst.model`。

### 3.2. 准备手写数字

准备的数字的图片如下：
![0](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p3/0.png)、![1](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p3/1.png)、![4](https://raw.githubusercontent.com/yizhishi/yizhishi.github.io/master/images/1903-a-s-e-p3/4.png)

### 3.3. 验证手写数字

验证手写数字代码如下：

``` python
import tensorflow as tf
import numpy as np
import os
from PIL import Image

# 测试保存的模型
def predict(image_path):
    # 加载保存的模型
    new_model = tf.keras.models.load_model('myminst.model')

    img = Image.open(image_path).convert('L').resize((28, 28))
    flatten_img = np.array(img) / 255
    flatten_img = flatten_img.reshape(28, 28)
    x = np.array([1 - flatten_img])
    y = new_model.predict(x)

    print('image: {}, predict digit: {}'.format(image_path, np.argmax(y[0])))

def main():
    file_dir = 'C:\\tool\\python_tutorial\\tensorflow_tutorial\\images\\'
    list = os.listdir(file_dir)
    for i in range(0, len(list)):
        image_path = file_dir + list[i]
        predict(image_path)

main()
```

验证结果如下：

``` bash
image: C:\tool\python_tutorial\tensorflow_tutorial\images\0.png, predict digit: 0
image: C:\tool\python_tutorial\tensorflow_tutorial\images\1.png, predict digit: 1
image: C:\tool\python_tutorial\tensorflow_tutorial\images\4.png, predict digit: 4
```

结论：成功识别3张图片里的数字，predict digit分别为0、1、4。
