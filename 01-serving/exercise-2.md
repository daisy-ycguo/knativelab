# 通过Knative命令行工具创建第一个Knative服务

Knative Client是Knative的命令行项目，仍在开发过程中。这个实验将通过Knative命令行工具`kn`创建第一个Knative的服务。 这个服务是一个产生连续斐波纳契数列的应用。它部署后将暴露出一个端口（endpoint），向这个端口发送GET请求，就会得到斐波纳契数列的前n个数字。其中`n`通过`/`之后的参数传入。

## 前提

* 通过kubectl连接到了云端的Kubernetes集群；
* 启动CloudShell云端命令行窗口；
* Istio和Knative在IBM Kubernetes Cluster上安装完毕。

## 第一步：获取本次实验的代码

在CloudShell窗口中，使用git命令获取本次实验的代码。

```text
git clone https://github.com/daisy-ycguo/knativelab.git
```

这个命令将在当前目录下创建一个knativelab的目录。本次实验所需的源代码，均在`knativelab/src`下面。

## 第二步：部署Knative服务

产生斐波纳契数列的应用，已经被打包为一个Docker镜像，上传到了`docker.io/ibmcom/fib-knative`。现在我们将使用这个镜像以及`kn`命令创建Knative服务。

1. 部署服务：

   ```text
    kn service create --image docker.io/ibmcom/fib-knative fib-knative
   ```

2. 观察Kubernetes的pod初始化及启动：

   ```text
    kubectl get pods --watch
   ```

   到pod进入running状态，就说明服务已经部署好了。 输入`ctrl+c`结束观察进程。

3. 获得该服务的域名

每个Knative的Service都赋予了一个域名，使用这个域名可以访问到这个服务。执行下面的命令，获取服务域名信息：

   ```text
    kn service get fib-knative
   ```

域名大约是这个样子的：`fib-knative.default.bmv-knative-lab.us-south.containers.appdomain.cloud`。因为每个人使用的IKS不同，域名也略有差别。

4. 将域名配置为环境变量，便于后面使用：

   ```text
    export MY_DOMAIN=<your_app_domain_here>
   ```

5. 调用服务

现在我们可以调用这个Knative服务了。我们将使用`curl`命令直接向这个域名发送HTTP GET请求。请注意域名后面`/`之后的，是参数`number`，表示返回数字的个数，这里设为5。它应该返回5个斐波纳契数。

   ```text
    curl $MY_DOMAIN/5
   ```

   正确的输出为:

   ```text
    [1,1,2,3,5]
   ```

恭喜你！你已经部署完成第一个Knative服务了。你也可以尝试发送不同的`number`。

6. 观察Kubernetes Pod自动回收到零

Knative服务，具体是由Kubernetes的Pod来实现的。作为Serverless的服务，当该服务在一定时间（大约为90秒钟）内不被调用时，Pod资源应该被回收；而再次调用时，Pod应该会自动启动。现在我们来观察Pod的结束。 

运行该命令，直到Pod进入`Terminating`状态，并消失。大约需要等90秒钟。

   ```text
    kubectl get pods --watch
   ```
   输入`ctrl+c`结束观察。

这时，虽然Pod已经回收了，但是Knative Service仍然存在。观察
   ```text
    kn service list
   ```
返回的服务列表中，fib-knative仍然存在。

7. 观察一个全新的Kubernetes Pod自动启动

我们将再次通过curl命令调用Knative服务，请注意这次结果的返回比较慢，大约需要等待数秒钟。这是因为Knative需要启动一个全新的Pod用于处理该服务。

执行下面命令，等待数秒钟后，将返回5个斐波纳契数。
   ```text
    curl $MY_DOMAIN/5
   ```

再次观察，注意到一个全新的对应该服务的Pod被启动并运行了。
```
kubectl get pods
```

Continue on to [exercise 3](../exercise-3.md).

