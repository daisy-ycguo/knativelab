# 为Trigger增加过滤器Filter（高级）

上面的实验中，我们创建了心跳事件源，这次实验我们将增加一个事件源`CronJobSource`，它的消息也会发送给缺省的Broker。我们将首先观察到Broker接收到来自两个事件源的消息，转发给`event-display`并打印出来。接着，通过设定过滤器，我们让`event-display`只接收一种消息源产生的消息。

***注意*** 下面的操作要求在目录`knativelab/src/brokertrigger`中进行，可以在CloudShell窗口执行下面命令进入该目录：
```
cd ~/knativelab/src/brokertrigger/
```

## 步骤一：创建第二个事件源`cronjobs`

1. 创建`CronJobSource`

下面命令将创建`cronjobs`事件源，运行命令：
```text
kubectl apply -f cronjob.yaml
```

期待输出：
```
cronjobsource.sources.eventing.knative.dev/cronjobs created
```

检查cronjobs已经被创建，运行命令：
```
kubectl get CronJobSource
```

期待输出：
```
NAME       AGE
cronjobs   23s
```

2. 检查`event-display`的日志

查看`event-display`，你将会看到两种类型的消息，分别来自`heartbeats-sender` and `cronjobs`，运行命令:

```text
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

在日志能能看到2种类型的消息，来自`cronjobs`的消息带有`Hello world!`字符串，而来自`heartbeats-sender`的消息则带有心跳次数`"id": 26`。

观察完毕，使用`ctrl + c`结束进程。

## 步骤二：增加过滤器Filter

我们先来看一下`trigger2.yaml`的内容，与之前的`trigger1.yaml`相比，它增加了过滤器的配置信息，运行命令：

```text
cat trigger2.yaml
```

期待输出：
```
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  filter:
    sourceAndType:
      type: dev.knative.cronjob.event
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
```

可以看到，它的`spec`中的`filter`表明，这次订阅只针对那么类型为`dev.knative.cronjob.event`的事件消息，即由`cronjobs`产生的消息。

使用`trigger2.yaml`创建新的`mytrigger`，运行命令：

```text
kubectl apply -f trigger2.yaml
```

期待输出：
```
trigger.eventing.knative.dev/mytrigger configured
```

查看`mytrigger`已经创建好，运行命令：
```text
kubectl get trigger
```

期待输出：
```
NAME        READY     REASON    BROKER    SUBSCRIBER_URI                                    AGE
mytrigger   True                default   http://event-display.default.svc.cluster.local/   29s
```

## 步骤三：检查event-display的日志

用这个命令查看`event-display`的日志，运行命令：
```
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

可以看到，现在日志中显示的，只有来自`cronjobs`产生的消息了，证明Filter已经生效。

观察完毕，使用`ctrl + c`结束进程。

## 步骤四：删除所创建的对象

通过下面命令删除实验中创建的Trigger，事件源以及服务，运行命令：
```
source deleteall.sh
```

期待输出：
```
trigger.eventing.knative.dev "mytrigger" deleted
cronjobsource.sources.eventing.knative.dev "cronjobs" deleted
containersource.sources.eventing.knative.dev "heartbeats-sender" deleted
service.serving.knative.dev "event-display" deleted
```

恭喜你，你已经完成了Eventing的全部实验！