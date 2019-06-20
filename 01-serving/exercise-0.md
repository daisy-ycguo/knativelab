# 准备运行时环境

Knative Lab使用了IBM公有云上的Kubernetes集群，以及一个云上的命令行窗口CloudShell。您只需要拥有IBM Cloud的注册账号，就可以进行下面的操作。

## 前提

* 拥有一个IBM Cloud账号，也被称为IBM ID。如果没有注册，请到[http://cloud.ibm.com](http://cloud.ibm.com)上注册。
* 准备一个可以联网的浏览器，推荐Chrome，Firefox，和Safari。

## 第一步：分配Kuberntes集群

我们预先为这次实验创建了若干个多节点的Kubernetes集群，请您到IBM工作人员那里分配一个Kubernetes集群。 分配到集群后，请记住您的集群的名字。

## 第二步：准备CloudShell

访问[CloudShell](https://cloudshell-console-ikslab.us-south.cf.cloud.ibm.com/)，咨询IBM工作人员获取访问密码。输入密码后，就进入CloudShell页面。

![](https://github.com/daisy-ycguo/knativelab/raw/master/images/cloudshell-overview.png)

在CloudShell页面中，点击右上角您的用户名，会弹出一个下拉框，选择IBM。 

![](https://github.com/daisy-ycguo/knativelab/raw/master/images/cloudshell-account.png)

点击右上角用户名IBM左侧的命令行窗口图标，页面会开始刷新。大约等待几分钟，一个云上的命令行窗口就准备好了。
在命令行窗口中输入几条命令，如`git`或者`kubectl`或者`kn`，看到正确返回后，就可以开始使用了。

![](https://github.com/daisy-ycguo/knativelab/raw/master/images/cloudshell-terminal.png)

## 第三步：连接到您的Kubernetes集群

1. 在CloudShell页面，输入

   ```text
   export MYCLUSTER=<your_cluster_name>
   ```

2. 获取你的集群的更多信息：

   ```text
   $ ibmcloud ks cluster-get $MYCLUSTER
   Retrieving cluster kubeconsh-guoyc...
   OK
   
   
   Name:                           kubeconsh-guoyc
   ID:                             de69ab0ff1904720bc8835fd84211c0b
   State:                          normal
   Created:                        2019-06-16T10:27:06+0000
   Location:                       syd01
   Master URL:                     https://c2.au-syd.containers.cloud.ibm.com:20904
   Public Service Endpoint URL:    https://c2.au-syd.containers.cloud.ibm.com:20904
   Private Service Endpoint URL:   -
   Master Location:                Sydney
   Master Status:                  Ready (1 day ago)
   Master State:                   deployed
   Master Health:                  normal
   Ingress Subdomain:              kubeconsh-guoyc.au-syd.containers.appdomain.cloud
   Ingress Secret:                 kubeconsh-guoyc
   Workers:                        1
   Worker Zones:                   syd01
   Version:                        1.12.9_1557* (1.13.7_1526 latest)
   Owner:                          guoyingc@cn.ibm.com
   Monitoring Dashboard:           -
   Resource Group ID:              2a926a9173174d94a6eb13284e089f88
   Resource Group Name:            default

   *To update to 1.13.7_1526 version, run 'ibmcloud ks cluster-update --cluster kubeconsh-guoyc --kube-version 1.13.7_1526'. Review and make any required version changes before you update: ibm.biz/iks-versions
   ```

3. 下载你的集群的配置文件到CloudShell终端：

   ```text
   $ ibmcloud ks cluster-config $MYCLUSTER
   OK
   The configuration for kubeconsh-guoyc was downloaded successfully.
   
   Export environment variables to start using Kubernetes.
   
   export KUBECONFIG=/usr/shared-data/cloud-ibm-com-47b84451ab70b94737518f7640a9ee42-1/.bluemix/plugins/container-service/clusters/kubeconsh-guoyc/kube-config-syd01-kubeconsh-guoyc.yml
   ```

4. 上面一条命令输出的最后是一个高亮的黄色的export命令，在CloudShell中拷贝该命令，并执行：

   ```text
   export KUBECONFIG=/usr/shared-data/cloud-ibm-com-47b84451ab70b94737518f7640a9ee42-1/.bluemix/plugins/container-service/clusters/......
   ```

5. 验证您已经可以用kubectl连接到云端的Kubernetes集群：

   ```text
   $ kubectl get nodes
   NAME             STATUS   ROLES    AGE     VERSION
   10.138.173.126   Ready    <none>   3d16h   v1.13.9+IKS
   ```

   这里，`kubectl get nodes`能够得到正确返回，看到您的集群中的节点，那么您就可以继续下面的实验了。

继续 [exercise 1](./exercise-1.md).

