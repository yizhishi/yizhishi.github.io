---
layout: post
title: windows安装Knative
date: 2020-01-13 00:15:08 +0000
category:
  - cloud-native
tags:
  - serverless
comment: false
reward: false
excerpt: windows安装Knative
---

[windows 安装 Knative](https://knative.dev/docs/install/)，比较繁琐，害怕出错，记录下自己的安装历程。

## 0 [install minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/#installation)

首先，需要一个k8s集群，选择简单的minikube

### 0.1 [install minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

#### 0.1.0. check my pc supports virtualization

``` sh
systeminfo

#命令行显示支持
Hyper-V 要求:     虚拟机监视器模式扩展: 是
                  固件中已启用虚拟化: 否
                  二级地址转换: 是
                  数据执行保护可用: 是
```

#### 0.1.1  [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-windows)

- install binary with curl

``` sh
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/windows/amd64/kubectl.exe
```

- add kubectl.exe to path

- 验证是否安装成功

``` java
kubectl version --client
# 命令行显示
Client Version: version.Info{...}
```

- [Verifying kubectl configuration](https://kubernetes.io/docs/tasks/tools/install-kubectl/#verifying-kubectl-configuration)

#### 0.1.2 [Install Minikube via direct download](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube-via-direct-download)

- 下载[minikube-windows-amd64](https://github.com/kubernetes/minikube/releases/latest)，改名`minikube.exe`，添加进path。

- 验证是否安装成功。**卡在这一步好久**

``` sh
minikube start --vm-driver=hyperv
```

提示我一大堆，如下：

``` sh
* Microsoft Windows 10 Enterprise LTSC 2019 10.0.17763 Build 17763 上的 minikube v1.6.2
* Selecting 'hyperv' driver from user configuration (alternates: [])

! 'hyperv' driver reported an issue: C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online failed:
Get-WindowsOptionalFeature : �����Ĳ�����Ҫ������
����λ�� ��:1 �ַ�: 1
+ Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-WindowsOptionalFeature], COMException
    + FullyQualifiedErrorId : Microsoft.Dism.Commands.GetWindowsOptionalFeatureCommand


* Suggestion: Start PowerShell as Administrator, and run: 'Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All'
* 文档：https://minikube.sigs.k8s.io/docs/reference/drivers/hyperv/

X hyperv does not appear to be installed
```

按建议操作，没有起作用，**决定重装windows，因为可以使用教育版的。**

### 0.2 [start minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/#quickstart)

### 0.3 [other operation](https://kubernetes.io/docs/setup/learning-environment/minikube/)
