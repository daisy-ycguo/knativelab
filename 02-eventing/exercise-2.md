# 使用Channel和Subscription

这里我们将使用Channel和Subscription管理事件和订阅。我们仍将使用定时事件`Cronjob`。订阅事件的可访问的对象（Accessable）仍然是Knative Service `event-display`。

![](https://github.com/daisy-ycguo/knativelab/raw/master/images/Knative-middlemodel.png)

***注意*** 下面的操作要求在目录`knativelab/src/subscription`中进行，可以在CloudShell窗口执行下面命令进入该目录：
```
cd ~/knativelab/src/subscription/
```

## 步骤一：创建Channel

1. 查看预装的Channel供货商

  Knative中预装了几个Channel的供货商，通过下面命令查看预装的Channel供货商有两个`in-memory`和`in-memory-channel`，它们其实并没什么差别。

  运行命令：
  ```text
  kubectl get ClusterChannelProvisioner -n knative-eventing
  ```

  期待输出：
  ```
  NAME                READY     REASON    AGE
  in-memory           True                1h
  in-memory-channel   True                1h
  ```

2. 使用供货商`in-memory-channel`创建Channel。

  首先查看`channel.yaml`的内容，它表示将使用`in-memory-channel`创建一个Channel`mychannel`，运行命令：
  ```
  cat channel.yaml
  ```

  期待输出：
  ```
  apiVersion: eventing.knative.dev/v1alpha1
  kind: Channel
  metadata:
    name: mychannel
  spec:
    provisioner:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: ClusterChannelProvisioner
      name: in-memory-channel
  ```

  使用下面命令创建Channel：
  ```
  kubectl apply -f channel.yaml
  ```

  期待输出：
  ```
  channel.eventing.knative.dev/mychannel created
  ```

  查看`mychannel`已经创建好，运行命令：
  ```
  kubectl get channel
  ```

  期待输出：
  ```
  NAME        READY   REASON   AGE
  mychannel   True             55s
  ```

## 步骤二：创建Cronjob事件源

Knative预先安装了定时事件源类型CronJobSource，可以用这个事件源来定时发送事件消息。

  1. 创建Cronjob事件源

  我们先来看一下`cronjob.yaml`的内容，这里描述了定时事件源的配置信息。
  
  运行命令：
  ```text
  cat cronjob.yaml
  ```

  期待输出：
  ```
  apiVersion: sources.eventing.knative.dev/v1alpha1
  kind: CronJobSource
  metadata:
    name: cronjobs
  spec:
    schedule: "*/1 * * * *"
    data: "{\"message\": \"Hello world!\"}"
    sink:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: Channel
      name: mychannel
  ```

  可以看到，它的`spec`主要包含三部分内容，其中`schedule`和`data`与上次实验完全相同，而`sink`则不同。`sink`定义了事件消息将被转发到`mychannel`中。

  通过下面命令创建事件源`cronjobs`:
  
  运行命令：
  ```text
  kubectl apply -f cronjob.yaml
  ```

  期待输出：
  ```
  cronjobsource.sources.eventing.knative.dev/cronjobs created
  ```

2. 检查该事件源已经被创建

  运行命令：
  ```text
  kubectl get cronjobsource
  ```

  期待输出：
  ```
  NAME       AGE
  cronjobs   44s
  ```

3. 检查承载Cronjob应用的Pod已经启动

  运行命令：
  ```
  kubectl get pods
  ```

  期待输出：
  ```
  NAME                                      READY   STATUS    RESTARTS   AGE
  cronjob-cronjobs-9wcq9-7d75fdbd8c-m5ddh   1/1     Running   0          21s
  ```

## 步骤三：定义Subscription

虽然Cronjob事件源`cronjobs`已经启动，并已经开始定期的把消息发送到`mychannel`，但是还没有任何订阅者。现在我们来创建订阅者，让`event-display`订阅到`mychannel`。

1. 创建Subscription

  我们先来看一下`subscription.yaml`的内容，这里描述了定时事件源的配置信息。

  运行命令：
  ```text
  cat subscription.yaml
  ```

  期待输出：
  ```
  apiVersion: eventing.knative.dev/v1alpha1
  kind: Subscription
  metadata:
    name: mysubscription
    namespace: default
  spec:
    channel:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: Channel
      name: mychannel
    subscriber:
      ref:
        apiVersion: serving.knative.dev/v1alpha1
        kind: Service
        name: event-display
  ```

  可以看到，它的`spec`主要包含两部分内容：
  - channel：所订阅的Channel；
  - subscriber：Channel的订阅者，该Channel中的事件消息将被转发到所有订阅者。这里订阅者为`event-display`。

  通过下面命令创建Subscription`mysubscription`:

  运行命令：
  ```text
  kubectl apply -f subscription.yaml
  ```

  期待输出：
  ```
  subscription.eventing.knative.dev/mysubscription created
  ```

2. 检查Subscription已经被创建

  运行命令：
  ```text
  kubectl get subscription
  ```

  期待输出：
  ```
  NAME             READY   REASON   AGE
  mysubscription   True             29s
  ```

## 步骤三：检查event-display的日志

下面命令将列出所有运行的Pod，观察`event-display`应用所在的Pod已经开始运行。Cronjob每1分钟产生一个消息，有时需要等待1分钟才能看到`event-display`所在的Pod。

运行命令：
```
kubectl get pods
```

期待输出：
```
NAME                                              READY   STATUS    RESTARTS   AGE
cronjob-cronjobs-9wcq9-7d75fdbd8c-m5ddh           1/1     Running   0          8m54s
event-display-46hhp-deployment-597487d855-67gvm   2/2     Running   0          50s
```

`event-display`所在的Pod开始运行后，可以查看`event-display`的日志，CloudEvent消息已经被打印出来，这说明了`cronjobs`创建后，产生的定时CloudEvent消息，已经被`event-display`接收并打印在日志中：
```
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```
观察完毕，使用`ctrl + c`结束进程。

## 步骤四：删除事件源、Channel以及Subscription

现在我们先删除这次实验中创建的对象，因为接下来的实验我们将采用其他方法管理事件和订阅。

运行命令：
```
kubectl delete -f .
```

期待输出：
```
channel.eventing.knative.dev "mychannel" deleted
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
subscription.eventing.knative.dev "mysubscription" deleted
```

`event-display`并没有删除，我们还将在下面的实验中用到它。但因为它是Serverless的服务，一段时间不被调用将会被平台自动收回。

```
kubectl get pods
```

可能的输出：
```
NAME                                              READY   STATUS    RESTARTS   AGE
event-display-rpxcz-deployment-58676c965b-2j6jl   2/2     Running   0          3m46s
```
或者
```
NAME                                              READY   STATUS        RESTARTS   AGE
event-display-rpxcz-deployment-58676c965b-2j6jl   2/2     Terminating   0          4m14s
```
或者
```
No resources found.
```

继续 [exercise 3](./exercise-3.md).