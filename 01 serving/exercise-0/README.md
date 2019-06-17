## 准备运行时环境

Knative Lab使用了IBM公有云上的Kubernetes集群，以及一个云上的命令行窗口CloudShell。您只需要拥有IBM Cloud的注册账号，就可以进行下面的操作。如果没有注册，请到http://cloud.ibm.com上注册。

### 分配Kuberntes集群

我们提前预先创建了若干个多节点的Kubernetes集群用于这次实验，请您到IBM工作人员那里分配一个Kubernetes集群。
分配到集群后，您可以登陆http://cloud.ibm.com，在您的账号下查看Kubernetes集群。

### 准备CloudShell

访问https://cloudshell-console-ikslab.us-south.cf.cloud.ibm.com/，输入密码后（密码见群消息），就进入CloudShell页面。

在CloudShell页面中，点击右上角您的用户名，会弹出一个下拉框，选择IBM。
点击右上角用户名IBM左侧的CloudShell图标，页面会开始刷新。大约等待几分钟，一个云上的命令行窗口就准备好了。

在命令行窗口中输入kubectl，看到正确返回后，就可以开始使用了。
```
git
```

### 获取本次实验的代码

使用git命令获取本次实验的代码。

```
git clone https://github.com/daisy-ycguo/knativelab.git
```

### 连接到您的Kubernetes集群

输入您的用户名和密码登陆IBM Cloud，在IBM Cloud上，找到资源概要（Resource Summary)。

点击Kubernetes Cluster，找到为您分配的那个Kubernetes集群。点击该集群的名字，打开您的集群页面。

在您的集群页面，点击访问（Access），就会看到一个详细的客户端链接集群的说明。请您在CloudShell窗口按照这个说明来操作。注意！！！“下载和安全CLI工具”这步跳过，不需要执行。这是CloudShell里预先安装了CLI的工具及其插件。

最后一步，`kubectl get nodes`能够得到正确返回，看到您的集群中的节点，那么您就可以继续下面的实验了。


继续 [exercise 1](../exercise-1/README.md).
