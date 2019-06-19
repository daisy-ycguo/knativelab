# 流量管控

在这个实验中，我们将创建第二个版本的菲波纳契数列的服务，这个服务将从0开始构造菲波纳契数列，而不是从1开始。这个新应用的镜像也已经构建好，并且上传到了docker hub中。

## 部署第二个版本vnext

1. 获取第一个Revision的名字。

   通过这个命令我们将获取fib-knative服务的Revision：
   ```text
    kubectl get revision
   ```

   期待的输出为:

   ```text
    NAME                SERVICE NAME        GENERATION   READY   REASON
    fib-knative-rgqjl   fib-knative-rgqjl   1            True
   ```
   请注意`fib-knative-rgqjl`就是第一个Revision的名字，将它拷贝下来待用。

2. 使用YAML文件描述新版本的Knative Service

   新版本的fib-knative包含流量控制的信息，暂时无法通过`kn`实现部署（`kn`仍然是正在开发中的项目），我们将使用YAML文件以及`kubectl apply`命令来部署新版本。

   我们先来看一下`fib-service2.yaml`的内容，这里描述了新版本的配置信息：
   ```text
    $ cat fib-service2.yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
        name: fib-knative
        namespace: default
    spec:
        release:
            revisions: ["fib-knative-xxxxx", "@latest"]
            rolloutPercent: 10
            configuration:
                revisionTemplate:
                    spec:
                        container:
                            image: docker.io/ibmcom/fib-knative:vnext
   ```

   接下来编辑这个文件，将`fib-knative-xxxxx`替换为相应的第一个版本的名字，使用下面命令完成替换：
   ```
   
   ```
   再次使用cat查看编辑后的文件，注意版本名称`fib-knative-xxxxx`已经被替换为了正确的字符串：
   ```text
    $ cat fib-service2.yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
        name: fib-knative
        namespace: default
    spec:
        release:
            revisions: ["fib-knative-rgqjl", "@latest"]
            rolloutPercent: 10
            configuration:
                revisionTemplate:
                    spec:
                        container:
                            image: docker.io/ibmcom/fib-knative:vnext
   ```

   请注意，这里的`rolloutPercent: 10`表明将切换10%的流量到`@latest`版本，也就是最新的版本。

3. 部署新版本

   使用如下的`kubectl apply`命令来部署新版本：
   ```text
    kubectl apply -f fib-service2.yaml
   ```

5. Let's run some load against the app, just asking for the first number in the Fibonacci sequence so that we can clearly see which revision is being called.

   ```text
    while sleep 0.5; do curl "$MY_DOMAIN/1"; done
   ```

   Expected Output:

   ```text
    [1][1][0][1][1][1][1][1][1][1][1]
   ```

6. We should see that the curl requests are routed approximately 90/10 between the two revisions. Let's kill this process using `ctrl + c`.

7. Delete fib-knative service by:

   ```text
    kubectl delete -f fib-service.yaml
   ```

Congratulations! You've completed the lab! If you have tons of time left over, and are interested in diving deeper, we've included 2 advanced exercises you could complete.

