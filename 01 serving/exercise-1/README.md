## 安装Istio和Knative

Knative基于Kubernetes和Istio。IBM公有云上提供的Kubernetes集群可以一键安装Istio和Knative，省去安装的烦恼。

### 使用IBM Cloud命令行工具安装

1. 一键安装

在CloudShell窗口中执行下面的命令，这个命令会自动安装Istio和Knative。
```
ibmcloud ks cluster-addon-enable knative --cluster mycluster
```

2. 检查安装后的Knative

查看所有的名称空间：
```
kubectl get namespace
```

查看istio-system下面的pod，确保都在running状态：
```
kubectl get pods -n istio-system
```

查看knative-serving下面的pod，确保都在running状态：
```
kubectl get pods -n knative-serving
```

3. 启动Istio自动注入（可选）

在CloudShell窗口中执行：
```
kubectl label namespace default istio-injection=enabled
```

4. 启用fluentd日志（可选）

```
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
```
Disable logging
```
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready-
```
Check
```
kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
```

继续 [exercise 2](../exercise-2/README.md).

5. 卸载（可选）
如果需要卸载Knative和Istio，在CloudShell中执行这些操作：
```
ibmcloud ks cluster-addon-disable knative --cluster mycluster
ibmcloud ks cluster-addon-disable istio --cluster mycluster
```

6. 参考资料
想学习Kubernetes可以访问[Kube101](https://github.com/IBM/kube101/tree/master/workshop)。
想学习Istio可以访问[Istio101](https://github.com/IBM/istio101/tree/master/workshop).