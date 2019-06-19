## 通过Knative命令行工具创建第一个Knative服务

Knative Client是Knative的命令行项目，仍在开发过程中。这个实验将通过Knative命令行工具`kn`创建第一个Knative的服务。
这个服务是一个产生连续斐波那且数列的应用。它部署后将暴露出一个端口（endpoint），向这个端口发送GET请求，就会得到斐波那契数列的前n个数字。其中`n`通过`/`之后的参数传入。

### 前提
- 通过kubectl连接到了云端的Kubernetes集群；
- 启动CloudShell云端命令行窗口；
- Istio和Knative在IBM Kubernetes Cluster上安装完毕。

### 第一步：获取本次实验的代码

在CloudShell窗口中，使用git命令获取本次实验的代码。

```
git clone https://github.com/daisy-ycguo/knativelab.git
```
这个命令将在当前目录下创建一个knativelab的目录。本次实验所需的源代码，均在`knativelab/src`下面。

### 第二步：部署Knative服务

产生斐波那契数列的应用，已经被打包为一个Docker镜像，上传到了`docker.io/ibmcom/fib-knative`。现在我们将使用这个镜像以及`kn`命令创建Knative服务。

1. 部署服务：

    ```
    kn service create --image docker.io/ibmcom/fib-knative fib-knative
    ```

2. 观察Kubernetes的pod初始化及启动：

    ```
    kubectl get pods --watch
    ```

    到pod进入running状态，就说明服务已经部署好了。
    输入`ctrl+c`结束观察进程。

3. Let's try out our new application! First, let's get the domain name that Knative assigned to the Service we just deployed. Run the following command, and note the value for `domain`. IBM Cloud Kubernetes Service sets the default domain name for Knative to match the domain name of your IBM Cloud Kubernetes Service cluster.

    ```
    kn service get fib-knative
    ```

4. The domain name should look something like `fib-knative.default.bmv-knative-lab.us-south.containers.appdomain.cloud`. We can set an environment variable so that we can use this throughout the lab:

    ```
    export MY_DOMAIN=<your_app_domain_here>
    ```
5. We can now curl this domain to try out our application. Notice that we're calling the `/` endpoint, and passing in a `number` parameter of 5. This should return the first 5 numbers of the fibonacci sequence.

    ```
    curl $MY_DOMAIN/5
    ```

    Expected Output:
    ```
    [1,1,2,3,5]
    ```

6. Congratulations! You've got your first Knative application deployed and responding to requests. Try sending some different number requests. If you stop making requests to the application, you should eventually see that your application scales itself back down to zero. Watch the pod until you see that it is `Terminating`. This should take approximately 90 seconds.

    ```
    kubectl get pods --watch
    ```

    Note: To exit the watch, use `ctrl + c`.

7. We'll redeploy this same application in a different way in the next exercise, so let's clean up.

    ```
    kn service delete fib-knative
    ```

Continue on to [exercise 3](../exercise-3.md).
