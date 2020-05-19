---
layout: post
title: 阿里云ecs部署Knative应用
date: 2020-03-31 00:15:08 +0000
category:
  - cloud-native
tags:
  - serverless
  - knative
comment: false
reward: false
excerpt: 阿里云ecs部署Knative应用
---

[Knative](https://knative.dev/) 是谷歌在2018年开源的 Serverless 框架，旨在提供一套简单易用的 Serverless 方案，把 Serverless 标准化。目前参与 Knative 项目的公司有：Google、Pivotal、IBM、Red Hat、SAP。

本文使用3台阿里云的ecs来搭建 Knative ，截止文章编写时， Knative 的版本是v0.13，需要：

- v1.15或更高版本的k8s集群
- 1.3.6版本的Istio（使用Istio做网络层）

## 1. [k8s](https://v1-15.docs.kubernetes.io/)

### 1.1. [安装kubeadm](https://v1-15.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

kubeadm 是一个构建k8s集群的工具，它提供的 init 和 join 命令是快速构建k8s集群的最佳实践。

#### 1.1.1. 设置 hostname

分别在 master 节点和 workloads 节点执行下边命令设置 hostname 。

``` sh
# 设置 master 节点的 hostname
hostnamectl --static set-hostname k8s-master

# 设置 node1 节点的 hostname
hostnamectl --static set-hostname k8s-node1

# 设置 node2 节点的 hostname
hostnamectl --static set-hostname k8s-node2
```

**以下 1.1.2~1.1.7 的操作需要在所有节点进行。**

#### 1.1.2. 设置 hosts

``` sh
vi /etc/hosts

#在 /ets/hosts 文件添加， master 和 node 节点的 ip
${master的私网IP}     k8s-master
${node1的私网IP}      k8s-node1
${node2的私网IP}      k8s-node2
```

<!-- 
#### 1.1.3. 停掉防火墙服务
``` sh
systemctl stop firewalld && systemctl disable firewalld
```
-->

#### 1.1.3. 安装 docker

使用 docker 作为容器运行时，1.15.2版本的 k8s 对应 docker 版本如下：

``` sh
Kubernetes 1.15.2   -->   Docker版本1.13.1、17.03、17.06、17.09、18.06、18.09
```

这里选择 18.06.1-ce 版本的 docker 进行安装

``` sh
# 安装 yum 工具包
yum install -y yum-utils

# 添加 yum 源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 安装 18.06.1-ce 版本的 docker
yum install -y docker-ce-18.06.1.ce-3.el7

# 启动 docker 服务并设置为开机启动
systemctl start docker && systemctl enable docker

# 验证是否安装成功
docker version

```

#### 1.1.4. 禁用 SELinux

>This is required to allow containers to access the host filesystem, which is needed by pod networks for example. You have to do this until SELinux support is improved in the kubelet.

 kubelet 暂不支持 SELinux ，所以禁用。

``` sh
# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

```

#### 1.1.5. 关闭交换内存

当内存不足时， linux 会自动使用 swap 将部分内存数据存放到磁盘中，这样会使性能下降，为了性能考虑推荐关掉。

``` sh
swapoff -a

vi /etc/fstab
# 注释掉 swap 相关行（如果有）
```

#### 1.1.6. 修改 iptables 相关参数

>Some users on RHEL/CentOS 7 have reported issues with traffic being routed incorrectly due to iptables being bypassed. You should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config

确保流量被正确路由。

``` sh
vi /etc/sysctl.conf

# /etc/sysctl.conf 添加如下内容
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

# 使配置生效
sysctl -p

```

#### 1.1.7. 安装 kubeadm 、 kubelet 、 kubectl

``` sh
# 配置 kubernetes.repo的源，官方源国内无法访问，使用阿里云的源
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
yum install -y kubeadm-1.15.2 kubelet-1.15.2 kubectl-1.15.2 --disableexcludes=kubernetes

# 启动kubelet服务
systemctl enable --now kubelet

```

### 1.2. [创建k8s集群](https://v1-15.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

#### 1.2.1. master 节点初始化

- 在 master 节点执行初始化命令。
  - `pod-network-cidr`：设定 pod 网络的IP地址网段，不同的网络插件使用的值有所不同， Calico 使用的是192.168.0.0/16， Canal 和 Flannel 使用的是10.244.0.0/16。
  - `image-repository`：镜像拉取地址，使用阿里云的镜像仓库。
  - `kubernetes-version`：指定k8s版本。

<!--  --apiserver-advertise-address=${master的私网IP}  -->

``` sh
# 初始化命令
kubeadm init --pod-network-cidr=192.168.0.0/16 --image-repository registry.aliyuncs.com/google_containers --kubernetes-version v1.15.2

```

``` sh
# 初始化结束后返回：
[init] Using Kubernetes version: v1.15.2
[preflight] Running pre-flight checks
  [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [*.*.*.* *.*.*.*]
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [*.*.*.* 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [*.*.*.* 127.0.0.1 ::1]
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 19.508137 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 419gig.hr760wuwlr6l8zat
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

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

- 确保 kubectl 正常工作。

root用户执行`export KUBECONFIG=/etc/kubernetes/admin.conf`。

非root用户执行如下命令。

``` sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- 给 kubectl 起个别名 k ，简化一部分操作。

``` sh
vi ~/.bashrc

# 在 .bashrc 添加一行，为kubectl起个别名k
alias k='kubectl'

# 刷新使修改生效
source ~/.bashrc
```

- 安装网络插件

执行`k get nodes` ，发现状态是`NotReady`，查看`kubelet`的日志发现网络没有就绪（这一点在 master 节点的初始化日志中有提示`You should now deploy a pod network to the cluster.`）。

``` sh
# 查看状态
k get nodes

# 状态
NAME          STATUS      ROLES     AGE     VERSION
k8s-master    NotReady    master    5m54s   v1.15.2

# 查看kubelet日志
journalctl -f -u kubelet

# 一部分日志
kubelet.go:2169] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
cni.go:213] Unable to update cni config: No networks found in /etc/cni/net.d
```

这是因为 k8s 本身并不提供网络功能，但是提供了容器网络接口 CNI 。有一系列开源的网络插件实现了 CNI 解决集群的容器联网问题，比如flannel、calico、canal等等，这里我选择[Calico](https://www.projectcalico.org/)作为解决方案。

``` sh
mkdir -p ~/calico/ && cd ~/calico/

wget https://docs.projectcalico.org/v3.8/manifests/calico.yaml

k apply -f calico.yaml

# 查看节点状态
k get nodes

# 状态
NAME          STATUS    ROLES     AGE   VERSION
k8s-master    Ready     master    11m   v1.15.2

```

节点状态已经是 Ready 。但是查看 pod 的状态，发现 calico-node 存在 READY 0/1 的情况。

``` sh
k get pod --all-namespaces

# pod的状态
NAMESPACE     NAME              READY   STATUS    RESTARTS    AGE
kube-system   calico-node-xxx   0/1     Running   0           118m

# 查看pod信息
k describe pod -n kube-system calico-node-xxx

# 看到报错
Readiness probe failed: calico/node is not ready: BIRD is not ready: BGP not established with
```

查看 calico-node 的详细信息后出现 Readiness probe failed: calico/node is not ready: BIRD is not ready: BGP not established with 的报错信息。因为官方的 getting-started 没有把 IP_AUTODETECTION_METHOD 这个IP检测方法的参数放入 calico.yaml 中， calico 会使用第一个找到的 network interface （往往是错误的interface），导致 calico 把 master 也算进 nodes ，于是 master BGP 启动失败，而其他 workers 则启动成功。

[解决方法](https://blog.crazyphper.com/2019/12/12/calico-%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E6%B1%87%E6%80%BB/)：

``` sh
vi ~/calico/calico.yaml

...
            # Cluster type to identify the deployment type
            - name: CLUSTER_TYPE
              value: "k8s,bgp"
            # Auto-detect the BGP IP address.

            # 新增部分开始
            - name: IP_AUTODETECTION_METHOD
              value: "interface=eth0"
            # value: "interface=eth.*"
            # value: "interface=can-reach=www.baidu.com"
            # 新增部分结束

            - name: IP
              value: "autodetect"
...
```

- master 节点参与 pod 调度

出于安全考虑，默认配置下不会将 pod 调度到 master 节点。如果希望将 k8s-master 也当作 workloads 节点使用，可以执行如下命令：

``` sh
k taint node k8s-master node-role.kubernetes.io/master-
```

如果要恢复 Master Only 状态，执行如下命令：

``` sh
k taint node k8s-master node-role.kubernetes.io/master=true:NoSchedule
```

#### 1.2.2. workloads节点加入集群

在 workloads 节点执行 master 节点初始化后返回的`kubeadm join ${master的私网IP}:6443 ...`，加入 k8s 集群。

``` sh
kubeadm join ${master的私网IP}:6443 --token ${your token} --discovery-token-ca-cert-hash sha256:${your sha256}

# 加入后命令行显示
[preflight] Running pre-flight checks
  [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

- 在 master 节点执行`k get nodes`查看机器状态。

``` sh
# 查看 nodes
k get nodes

# kubectl get nodes 返回
NAME          STATUS    ROLES     AGE     VERSION
k8s-master    Ready     master    23m     v1.15.2
k8s-node1     Ready     <none>    3m40s   v1.15.2
k8s-node1     Ready     <none>    3m43s   v1.15.2
```

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

## 2. [安装istio](https://knative.dev/docs/install/installing-istio/)

### 2.1 [helm安装](https://www.jianshu.com/p/2a96b06febc6)

[helm](https://helm.sh/)是 k8s 的包管理工具，类似 Linux 系统下的包管理器，如 yum。这里使用二进制方式进行安装。

``` sh
wget https://get.helm.sh/helm-v2.10.0-linux-amd64.tar.gz

tar -zxvf helm-v2.10.0-linux-amd64.tar.gz

mv linux-amd64/helm /usr/local/bin/helm

# 验证安装
helm version

# 创建serviceaccount
k -n kube-system create serviceaccount tiller

# 创建role
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

# 初始化
helm init --service-account tiller --tiller-image=registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.10.0 --upgrade --skip-refresh

helm repo update

```

### 2.2 istio安装

``` sh
cd ~

# 下载istio
export ISTIO_VERSION=1.3.6
curl -L https://git.io/getLatestIstio | sh -
cd istio-${ISTIO_VERSION}

# install the Istio CRDs
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done

# create istio-system namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  labels:
    istio-injection: disabled
EOF

```

这里使用没有 sidecar 的方式进行 istio 的安装。

``` sh
# 没有sidecar
helm template --namespace=istio-system --set prometheus.enabled=false --set mixer.enabled=false --set mixer.policy.enabled=false --set mixer.telemetry.enabled=false --set pilot.sidecar=false --set pilot.resources.requests.memory=128Mi --set galley.enabled=false --set global.useMCP=false --set security.enabled=false --set global.disablePolicyChecks=true --set sidecarInjectorWebhook.enabled=false --set global.proxy.autoInject=disabled --set global.omitSidecarInjectorConfigMap=true --set gateways.istio-ingressgateway.autoscaleMin=1 --set gateways.istio-ingressgateway.autoscaleMax=2 --set pilot.traceSampling=100 --set global.mtls.auto=false install/kubernetes/helm/istio > ./istio-lean.yaml

k apply -f ~/istio-${ISTIO_VERSION}/istio-lean.yaml

# 查看状态
k get pods -n istio-system --watch

```

## 3. [安装Knative](https://knative.dev/docs/install/any-kubernetes-cluster)

 Knative 现在有2个关键组件： Serving 和 Eventing （早期的 Building 组件已被 Tekton 替代）。 Knative 所需的镜像国内无法下载，我已经上传至[docker hub](https://hub.docker.com/)。

### 3.1. [安装Serving组件](https://knative.dev/docs/install/any-kubernetes-cluster/#installing-the-serving-component)

``` sh
# 下载所需镜像
docker pull yizhishi/knative_serving_cmd_autoscaler:v0.13.0
docker pull yizhishi/knative_serving_cmd_autoscaler-hpa:v0.13.0
docker pull yizhishi/knative_serving_cmd_controller:v0.13.0
docker pull yizhishi/knative_serving_cmd_activator:v0.13.0
docker pull yizhishi/knative_serving_cmd_networking_istio:v0.13.0
docker pull yizhishi/knative_serving_cmd_webhook:v0.13.0
docker pull yizhishi/knative_serving_cmd_queue:v0.13.0

# crd
k apply -f https://github.com/knative/serving/releases/download/v0.13.0/serving-crds.yaml

# core components，这个serving-core.yaml里的镜像地址我已经修改过
k apply -f https://raw.githubusercontent.com/yizhishi/knative-yaml/master/knative-serving/serving-core.yaml

# 这个serving-istio.yaml里的镜像地址我已经修改过
k apply -f https://raw.githubusercontent.com/yizhishi/knative-yaml/master/knative-serving/serving-istio.yaml

k get pod --all-namespaces -o wide --watch

k get service -n istio-system istio-ingressgateway

```

<!-- 
### 3.2. 安装`Eventing`组件
 -->

### 3.2. [部署Knative应用](https://knative.dev/docs/serving/getting-started-knative-app/)

``` sh
mkdir -p ~/knative-demo/ && cd ~/knative-demo/ && >service.yaml

vi service.yaml

# 将下边内容写进service.yaml
apiVersion: serving.knative.dev/v1 # Current version of Knative
kind: Service
metadata:
  name: helloworld-go # The name of the app
  namespace: default # The namespace the app will use
spec:
  template:
    spec:
      containers:
        - image: yizhishi/helloworld-go # The URL to the image of the app
          env:
            - name: TARGET # The environment variable printed out by the sample app
              value: "Go Sample v1"


k apply -f ~/knative-demo/service.yaml -v 7

# 查看knative service
k get ksvc helloworld-go

# 显示
NAME            URL                                        LATESTCREATED        LATESTREADY           READY   REASON
helloworld-go   http://helloworld-go.default.example.com   helloworld-go-xxxx   helloworld-go-xxxx    True
```

使用`curl -H "Host: helloworld-go.default.example.com" http://${master的私网IP}:31380`访问服务。

``` sh
# curl -H "Host: helloworld-go.default.example.com" http://${master的私网IP}:31380
Hello World: Go Sample v1!
```

<!-- 


监控

``` sh

# 创建namespace
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: knative-monitoring
  labels:
    serving.knative.dev/release: "v0.13.0"
EOF

# 修改 config-observability
kubectl edit cm -n knative-serving config-observability

# 在data下 添加 metrics.request-metrics-backend-destination: prometheus

kubectl apply --filename https://github.com/knative/serving/releases/download/v0.13.0/monitoring-metrics-prometheus.yaml

# 访问ui
kubectl port-forward -n knative-monitoring $(kubectl get pods -n knative-monitoring --selector=app=grafana --output=jsonpath="{.items..metadata.name}") 3000 --address ${私网IP}
```

kubectl 暴露
kubectl proxy --address='172.19.190.69'  --accept-hosts='^*$'
访问, http://47.100.160.30:8001/api/v1/namespaces/istio-system/services/zipkin:9411/proxy/zipkin/


kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686 --address 172.19.190.69


kubectl proxy --address='172.19.190.69'  --accept-hosts='^*$'

 -->

参考：

[Knative官网](https://knative.dev/)

[Kubernetes官网](https://v1-15.docs.kubernetes.io/)

[helm tiller 离线安装](https://www.jianshu.com/p/2a96b06febc6)

[calico 常见问题汇总](https://blog.crazyphper.com/2019/12/12/calico-常见问题汇总/)

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