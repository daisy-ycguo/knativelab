# 准备运行时环境

Knative Lab使用了IBM公有云上的Kubernetes集群，以及一个云上的命令行窗口CloudShell。您只需要拥有IBM Cloud的注册账号，就可以进行下面的操作。

## 前提

* 拥有一个IBM Cloud账号，也被称为IBM ID。如果没有注册，请到[http://cloud.ibm.com](http://cloud.ibm.com)上注册。
* 准备一个可以联网的浏览器，推荐Chrome，Firefox，和Safari。

## 第一步：分配Kuberntes集群

我们预先为这次实验创建了若干个多节点的Kubernetes集群，请您到IBM工作人员那里分配一个Kubernetes集群。 分配到集群后，请记住您的集群的名字。登陆[http://cloud.ibm.com](http://cloud.ibm.com)，在您的账号下查看这个Kubernetes集群。

## 第二步：准备CloudShell

访问[CloudShell](https://cloudshell-console-ikslab.us-south.cf.cloud.ibm.com/)，咨询IBM工作人员获取访问密码。输入密码后，就进入CloudShell页面。

在CloudShell页面中，点击右上角您的用户名，会弹出一个下拉框，选择IBM。 点击右上角用户名IBM左侧的命令行窗口图标，页面会开始刷新。大约等待几分钟，一个云上的命令行窗口就准备好了。

在命令行窗口中输入几条命令，如`git`或者`kubectl`或者`kn`，看到正确返回后，就可以开始使用了。

## 第三步：连接到您的Kubernetes集群

1. 在CloudShell页面，输入

   ```text
   export MYCLUSTER=<your_cluster_name>
   ```

2. 获取你的集群的更多信息：

   ```text
   ibmcloud ks cluster-get $MYCLUSTER
   ```

3. 下载你的集群的配置文件到CloudShell终端：

   ```text
   ibmcloud ks cluster-get $MYCLUSTER
   ```

4. 这条命令的最后是一个高亮的export命令，在CloudShell中拷贝该命令，并执行该命令：

   ```text
   export KUBECONFIG=/Users...
   ```

5. 验证您已经可以用kubectl连接到云端的Kubernetes集群：

   ```text
   kubectl get nodes
   ```

   最后一步，`kubectl get nodes`能够得到正确返回，看到您的集群中的节点，那么您就可以继续下面的实验了。

继续 [exercise 1](../exercise-1/).

