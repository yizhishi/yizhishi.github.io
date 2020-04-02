---
layout: post
title: 阿里云ecs从零开始部署Knative
date: 2020-03-31 00:15:08 +0000
category:
  - cloud-native
tags:
  - serverless
comment: false
reward: false
excerpt: 阿里云ecs部署Knative
---

[Knative](https://knative.dev/) 是谷歌在2018年开源的 Serverless 框架，旨在提供一套简单易用的 Serverless 方案，把 Serverless 标准化。目前参与 Knative 项目的公司有：Google、Pivotal、IBM、Red Hat、SAP。

本文使用3台阿里云的ecs来搭建 Knative ，截止文章编写时， Knative 的版本是v0.13，需要：

- v1.15或更高版本的k8s集群
- 1.3.6版本的Istio（使用Istio做网络层）

## 1. 安装 k8s 集群

### 1.1. k8s 集群准备工作

#### 1.1.1. 设置 hostname

分别在 master 和 node 执行下边命令设置 hostname 。

``` sh
# 设置 master 节点的 hostname
hostnamectl --static set-hostname k8s-master

# 设置 node1 节点的 hostname
hostnamectl --static set-hostname k8s-node1

# 设置 node2 节点的 hostname
hostnamectl --static set-hostname k8s-node2
```

**以下 1.1.2~1.1.8 的操作需要在所有节点进行。**

#### 1.1.2. 设置 hosts

``` sh
vi /etc/hosts

#在 /ets/hosts 文件下边添加， master 和 node 节点的 ip
${master的私网IP}     k8s-master
${node1的私网IP}      k8s-node1
${node2的私网IP}      k8s-node2
```

#### 1.1.3. 停掉防火墙服务

``` sh
systemctl stop firewalld && systemctl disable firewalld
```

#### 1.1.4. 禁用 SELinux

临时生效

``` sh
setenforce 0
```

永久生效，需要重启。

``` sh
vi /etc/selinux/config

# 修改 /etc/selinux/config 文件的 SELINUX=disabled
```

#### 1.1.5. 关闭交换内存

``` sh
swapoff -a

vi /etc/fstab
# 注释掉 swap 相关行（如果有）
```

#### 1.1.6. 修改 iptables 相关参数

``` sh
vi /etc/sysctl.conf

# /etc/sysctl.conf 添加如下内容
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

# 使配置生效
sysctl -p
```

#### 1.1.7. 安装 docker

使用1.15.2版本的 k8s ，对应 docker 版本如下：

``` sh
Kubernetes 1.15.2  -->Docker版本1.13.1、17.03、17.06、17.09、18.06、18.09
```

选择安装 18.06.1-ce 版本的 docker

``` sh
# 安装 yum 工具包
yum -y install yum-utils

# 添加 yum 源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装 18.06.1-ce 版本的 docker
yum install -y docker-ce-18.06.1.ce-3.el7

# 启动 docker 服务并设置为开机启动
systemctl start docker && systemctl enable docker

# 验证是否安装成功
docker version
```

#### 1.1.8. 安装 kubeadm 、 kubelet 、 kubectl

``` sh
# 配置 kubernetes.repo的源，官方源国内无法访问，使用阿里云源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 15.2 版本的kubeadm
yum install -y kubeadm-1.15.2 kubelet-1.15.2 kubectl-1.15.2

# 启动kubelet服务
systemctl start kubelet && systemctl enable kubelet
```

### 1.2 安装 k8s

#### 1.2.1 master 节点初始化

1. 在 master 节点执行初始化命令。

``` sh
# 初始化命令
kubeadm init --apiserver-advertise-address=${master的私网IP} --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.15.2 --pod-network-cidr=192.168.0.0/16

# 初始化结束后返回：
...
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join ${master的私网IP}:6443 --token ${your token} --discovery-token-ca-cert-hash sha256:${your sha256}
```

2. 在 node 节点执行 master 节点初始化后返回的`kubeadm join ${master的私网IP}:6443`，加入 k8s 集群。

``` sh
kubeadm join ${master的私网IP}:6443 --token ${your token} --discovery-token-ca-cert-hash sha256:${your sha256}

# 加入后命令行显示
...
...
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

3. 在 master 节点执行`kubectl get nodes`

先给 kubectl 起个别名 k ，简化一部分操作

``` sh
vi ~/.bashrc

# 在 .bashrc 添加一行，为kubectl起个别名k
alias k='kubectl'

# 刷新使修改生效
source ~/.bashrc


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 查看 nodes
k get nodes

# kubectl get nodes 返回
NAME         STATUS     ROLES    AGE   VERSION
k8s-master   NotReady   master   23m   v1.15.2
k8s-node1    NotReady   <none>   14m   v1.15.2
k8s-node2    NotReady   <none>   14m   v1.15.2
```

4. 安装网络插件——calico

第3步查看 nodes ，发现状态是`NotReady`，查看`kubelet`日志发现网络没有就绪。

``` sh
journalctl -f -u kubelet

# 日志
kubelet.go:2169] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
cni.go:213] Unable to update cni config: No networks found in /etc/cni/net.d
```

这是因为 k8s 本身并不提供网络功能，但是提供了容器网络接口（CNI）。有一系列开源的网络插件实现了CNI解决集群的容器联网问题，比如flannel、calico、canal等等，这里我选择 [calico](https://www.projectcalico.org/) 作为解决方案。

``` sh
mkdir -p /etc/cni/net.d/

mkdir -p ~/calico/ && cd ~/calico/

wget https://docs.projectcalico.org/v3.8/manifests/calico.yaml

k apply -f calico.yaml

# 查看节点状态
k get nodes

```

节点状态已经是`Ready`。但是查看pod的状态，发现`calico-no`存在`READY 0/1`的情况。

``` sh
k get pod --all-namespaces

# pod的状态
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-node-xxx                         0/1     Running   0          118m

# 查看pod信息
k describe pod -n kube-system calico-node-xxx

# 看到报错
Readiness probe failed: calico/node is not ready: BIRD is not ready: BGP not established with
```

查看`calico-node`的详细信息后出现`Readiness probe failed: calico/node is not ready: BIRD is not ready: BGP not established with`的报错信息。因为官方的getting-started太傻白甜，没有把`IP_AUTODETECTION_METHOD`这个IP检测方法的参数放入`calico.yaml`中，`calico`会使用第一个找到的`network interface`（往往是错误的interface），导致`calico`把`master`也算进`nodes`，于是`master BGP`启动失败，而其他`workers`则启动成功。



<!--
选择`flannel`作为网络插件

``` sh
mkdir -p ~/flannel/ && cd ~/flannel/

wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl apply -f kube-flannel.yml

# 查看状态
k get nodes
k get pod --all-namespaces

# 状态正常
```
-->

## 2. 安装 istio

参照[官网文档](https://knative.dev/docs/install/installing-istio/)进行安装，需要安装[helm](https://helm.sh/)

### 2.1 helm安装

helm 是 k8s 的包管理工具，类似Linux系统下的包管理器，如yum/apt等。

``` sh

```
























参考：
knative 官网
k8s 官网
calico 官网
heml 官网
https://blog.crazyphper.com/2019/12/12/calico-%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E6%B1%87%E6%80%BB/


<!--
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

**因为后边使用hyper-v启动minikube一直失败，决定安装[virtualbox](https://www.virtualbox.org/wiki/Downloads)，同时[禁用hyper-v](https://jingyan.baidu.com/article/86fae3461b50cc3c48121a4b.html)。**

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

- 这一步操作在minikube start后进行。[Verifying kubectl configuration](https://kubernetes.io/docs/tasks/tools/install-kubectl/#verifying-kubectl-configuration)，In order for kubectl to find and access a Kubernetes cluster, it needs a kubeconfig file, which is created automatically when you create a cluster using kube-up.sh or successfully deploy a Minikube cluster. By default, kubectl configuration is located at ~/.kube/config.

#### 0.1.2 [Install Minikube via direct download](https://kubernetes.io/docs/tasks/tools/install-minikube/#install-minikube-via-direct-download)

- 下载[minikube-windows-amd64](https://github.com/kubernetes/minikube/releases/latest)，改名`minikube.exe`，添加进path。

- 验证是否安装成功。

``` sh
 minikube start --vm-driver=virtualbox --registry-mirror=https://registry.docker-cn.com --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
```

``` sh
minikube status

#命令行显示
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

此时，也可以使用`kubectl cluster-info`进行 kubectl 的 Verifying kubectl configuration 操作

### 0.2 [start minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/#quickstart)

#### 0.2.1 Start Minikube and create a cluster:

在`0.1.2`已经使用镜像存储库启动了minikube，

For more information on starting your cluster on a specific Kubernetes version, VM, or container runtime, see [Starting a Cluster](https://kubernetes.io/docs/setup/learning-environment/minikube/#starting-a-cluster).

> minikube start使用过一次后，再次start，会提示如下：

``` sh
* Microsoft Windows 10 Pro 10.0.18362 Build 18362 上的 minikube v1.7.2
* Using the virtualbox driver based on user configuration
* 正在使用镜像存储库 registry.cn-hangzhou.aliyuncs.com/google_containers
* Reconfiguring existing host ...
* Starting existing virtualbox VM for "minikube" ...
* 正在 Docker 19.03.5 中准备 Kubernetes v1.17.2…
* 正在启动 Kubernetes ...
* Enabling addons: default-storageclass, storage-provisioner
* 完成！kubectl 已经配置至 "minikube"
```

#### 0.2.2 使用 kubectl 与 k8s 集群交互，创建名为 hello-minikube 的 `deployment`

``` sh
kubectl create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.10

# 命令行显示
deployment.apps/hello-minikube created
```

> [more about interacting with Your Cluster.](https://kubernetes.io/docs/setup/learning-environment/minikube/#interacting-with-your-cluster)

#### 0.2.3 暴露 hello-minikube 为一个`service`，使 hello-minikube 可以被访问到

``` sh
kubectl expose deployment hello-minikube --type=NodePort --port=8080

# 命令行显示
service/hello-minikube exposed
```

#### 0.2.4 查看`Pod`状态

```sh
kubectl get pod

# 命令行显示
NAME                              READY   STATUS         RESTARTS   AGE
hello-minikube-797f975945-66zr7   0/1     ErrImagePull   0          71m
# 再次 kubectl get pod，命令行返回
hello-minikube-797f975945-66zr7   0/1     ImagePullBackOff   0          84m
```

hello-minikube 的状态是 ImagePullBackOff，使用`kubectl describe pod hello-minikube-797f975945-66zr7`，查看。

``` sh
Events:
  Type     Reason   Age                    From               Message
  ----     ------   ----                   ----               -------
  Normal   Pulling  32m (x15 over 87m)     kubelet, minikube  Pullingimage "k8s.gcr.io/echoserver:1.10"
  Warning  Failed   12m (x310 over 87m)    kubelet, minikube  Error: ImagePullBackOff
  Normal   BackOff  2m15s (x350 over 87m)  kubelet, minikube  Back-off pulling image "k8s.gcr.io/echoserver:1.10"
```

目测是墙，导致没有镜像，需要[整个docker本地仓库]()。

### 0.3 [other operation](https://kubernetes.io/docs/setup/learning-environment/minikube/)





https://knative.dev/docs/install/knative-with-minikube/



https://knative.dev/docs/install/installing-istio/

https://knative.dev/docs/install/installing-istio/#installing-istio-without-sidecar-injection







参考

https://knative.dev/docs/install/knative-with-minikube/
with minikube 进行阿里云ecs 安装
-->