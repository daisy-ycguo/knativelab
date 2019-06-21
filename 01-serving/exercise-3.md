# 使用`kubectl apply`命令重建fib-service

Knative Client是正在开发中的项目，无法支持复杂的配置。这里我们将使用YAML文件以及`kubectl apply`命令来重新部署`fib-service`并进行流量控制。

## 前提

* 通过`kn`创建的fib-service已经删除。

## 第一步：获取本次实验的代码

在CloudShell窗口中，使用git命令获取本次实验的代码。

```text
git clone https://github.com/daisy-ycguo/knativelab.git
```

这个命令将在当前目录下创建一个knativelab的目录。本次实验所需的源代码，均在`knativelab/src`下面。运行命令
```
cd knativelab/src/fib-service
```
进入`knativelab/src/fib-service`目录。

## 第二步：部署Knative服务

1. 查看YAML文件

   我们先来看一下`fib-service.yaml`的内容，这里：
   ```text
    $ cat fib-service.yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: fib-knative
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: docker.io/ibmcom/fib-knative
   ```

2. 部署服务

   ```text
    $ kubectl apply -f fib-service.yaml
    service.serving.knative.dev/fib-knative created
   ```

3. 观察Kubernetes的pod初始化及启动：

   ```text
    kubectl get pods --watch
   ```

   到pod进入running状态，就说明服务已经部署好了。 输入`ctrl+c`结束观察进程。

4. 通过`kn`查看该服务

   通过`kubectl apply`命令创建的服务与通过`kn`创建的服务一样，可以通过`kn service list`显示出来，域名与之前是一样的。

   ```text
    $ kn service list
    NAME          DOMAIN                                                                GENERATION   AGE   CONDITIONS   READY   REASON
    fib-knative   fib-knative-default.knative-guoyc.au-syd.containers.appdomain.cloud   1            96s   3 OK / 3     True
   ```

5. 调用服务

   调用这个服务，同样会得到从1开始的菲波纳契数列。

   ```text
    curl $MY_DOMAIN/5
   ```

   正确的输出为:

   ```text
    [1,1,2,3,5]
   ```

继续 [exercise 4](./exercise-4.md).

