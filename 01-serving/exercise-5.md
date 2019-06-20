# 流量管控

在这个实验中，我们将创建第二个版本的菲波纳契数列的服务，这个新版本服务将从0开始构造菲波纳契数列，而不是从1开始。我们将操控对`fib-service`服务访问流量在新旧两个版本间分配。

这个新应用的镜像也已经构建好，并且上传到了docker hub中。

## 部署第二个版本vnext

1. 获取第一个Revision的名字。

   通过这个命令我们将获取fib-knative服务的Revision信息，其中第二行是名字：
   ```text
    $ kn revision list
    SERVICE       NAME                AGE   CONDITIONS   READY   REASON
    fib-knative   fib-knative-kv9n4   17m   4 OK / 5     True
   ```
   这里`fib-knative-kv9n4`就是第一个Revision的名字，将它拷贝下来待用。

2. 使用YAML文件描述新版本的Knative Service

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
   其中，镜像采用的是新版本`docker.io/ibmcom/fib-knative:vnext`，并且加入了流量控制信息，这里的`rolloutPercent: 10`表明将切换10%的流量路由到`@latest`版本，也就是最新的版本，90%的流量路由到Revision `fib-knative-xxxxx`。

3. 编辑fib-service2.yaml，写入正确的Revision名字

   接下来编辑fib-service2.yaml，将`fib-knative-xxxxx`替换为相应的第一个Revision的名字，使用下面命令完成替换。
   ***注意***这个命令里的`your_Revision_ID`就是刚才让大家拷贝的Revision的名字，类似于`fib-knative-kv9n4`：
   ```
   sed -i 's/fib-knative-xxxxx/your_Revision_ID/' fib-service2.yaml
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
            revisions: ["fib-knative-kv9n4", "@latest"]
            rolloutPercent: 10
            configuration:
                revisionTemplate:
                    spec:
                        container:
                            image: docker.io/ibmcom/fib-knative:vnext
   ```

3. 部署新版本

   使用如下的`kubectl apply`命令来部署新版本：
   ```text
    $ kubectl apply -f fib-service2.yaml
    service.serving.knative.dev/fib-knative configured
   ```

4. 观察两个Revision

   这时，如果列出所有的Revision，就能看到两个了：
   ```text
    $ kn revision list
    SERVICE       NAME                AGE   CONDITIONS   READY   REASON
    fib-knative   fib-knative-lzsjp   1m   4 OK / 5     True
    fib-knative   fib-knative-kv9n4   5m   4 OK / 5     True
   ```

5. 调用服务，观察流量管控

   现在我们`curl "$MY_DOMAIN/1"`时，有可能被路由到第一个Revision，也有可能被路由到第二个Revision。通过分析它的返回结果，来观察路由的分配。如果返回`[1]`，表明请求被路由到第一个Revision；如果返回`[0]`，则表示被路由到第二个Revision。如果多次调用，那么结果将是一个由`[1]`和`[0]`组成的序列，其中`[1]`与`[0]`出现的比例，大约是90:10的关系。

   ```text
    while sleep 0.5; do curl "$MY_DOMAIN/1"; done
   ```

   期待输出:

   ```text
    [1][1][0][1][1][1][1][1][1][1][1]
   ```

   观察完毕，使用`ctrl + c`结束进程。

7. 删除`fib-service`:

   ```text
    kubectl delete -f fib-service.yaml
   ```

恭喜你，你已经完成了第一部分的实验！

