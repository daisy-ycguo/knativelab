# 使用Broker和Trigger

这里我们将使用Broker和Trigger管理事件和订阅。我们将使用`ContainerSource`作为事件源。

发送到Broker的事件，将被转发给任何对该消息感兴趣的订阅者。

***注意*** 下面的操作要求在目录`knativelab/src/brokertrigger`中进行，可以在CloudShell窗口执行下面命令进入该目录：
```
cd ~/knativelab/src/brokertrigger/
```

## 步骤一：检查默认Channel的配置

在Knative中，通过ConfigMap`default-channel-webhook`配置了默认的Channel供货商，这个ConfigMap中定义了集群范围的默认Channel供货商以及名称空间范围的默认Channel供货商。通过下面命令可以看到，在集群范围内的默认Channel供货商为`in-memory`。

使用下面命令查询默认Channel，运行命令：
```text
kubectl get configmap default-channel-webhook -n knative-eventing -o jsonpath='{.data}'
```

期待输出：
```
map[default-channel-config:clusterdefault:
  apiversion: eventing.knative.dev/v1alpha1
  kind: ClusterChannelProvisioner
  name: in-memory
namespacedefaults:
  some-namespace:
    apiversion: eventing.knative.dev/v1alpha1
    kind: ClusterChannelProvisioner
    name: some-other-provisioner
```

## 步骤二：创建默认Broker

Broker可以通过两种方式创建：通过标记名称空间，可以创建默认的Broker。

运行命令：
```text
kubectl label namespace default knative-eventing-injection=enabled
```

期待输出：
```
namespace/default labeled
```

查看默认Broker已经被创建，运行命令:
```text
kubectl get broker
```

期待输出：
```
NAME      READY     REASON    HOSTNAME                                   AGE
default   True                default-broker.default.svc.cluster.local   14s
```

查看承载默认Borker的Pod已经启动，运行命令：
```
kubectl get pods
```

期待输出：
```
NAME                                              READY   STATUS    RESTARTS   AGE
default-broker-filter-798df8bc75-77m2r            1/1     Running   0          43s
default-broker-ingress-5fbb869648-q4xzb           1/1     Running   0          43s
```
他们一个是默认Broker的Ingress，负责接收消息，一个是默认Broker的过滤器，负责转发消息。

## 步骤三：创建心跳事件源

我们来创建一个心跳事件源，它将在规定的间隔内把心跳次数封装为事件消息发送给默认Broker。心跳事件源使用了`ContainerSource`，容器镜像则为`docker.io/daisyycguo/heartbeats-6790335e994243a8d3f53b967cdd6398`。

我们先来看一下`heartbeats.yaml`的内容，这里描述了定时事件源的配置信息。

运行命令：
```text
cat heartbeats.yaml
```

期待输出：
```
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ContainerSource
metadata:
  name: heartbeats-sender
spec:
  image: docker.io/daisyycguo/heartbeats-6790335e994243a8d3f53b967cdd6398
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
  args:
    - --period=1
  env:
    - name: POD_NAME
      value: "heartbeats"
    - name: POD_NAMESPACE
      value: "default"
```

可以看到，它的`spec`主要包含四部分内容：
- image：对于一个`ContainerSource`来说，这个属性是最关键的，它说明了这个事件源要启动哪个容器镜像；
- args和env：这是启动容器时，传递给容器的参数和环境变量；
- sink：说明了事件消息的发送目的地，这里的配置表示，事件消息将发送到默认的Broker中。

使用下面命令创建ContainerSource `heartbeats-sender`，运行命令：
```text
kubectl apply -f heartbeats.yaml
```

期待输出：
```
containersource.sources.eventing.knative.dev/heartbeats-sender created
```

查看`heartbeats-sender`已经创建好，运行命令：
```text
kubectl get ContainerSource
```

期待输出：
```
NAME                AGE
heartbeats-sender   2m
```

检查承载`heartbeats-sender`的Pod已经启动，运行命令：
```
kubectl get pods $(kubectl get pods --selector=eventing.knative.dev/source=heartbeats-sender 
```

期待输出：
```--output=jsonpath="{.items..metadata.name}")
NAME                                       READY   STATUS    RESTARTS   AGE
heartbeats-sender-dhnz8-569967d749-8wbwt   1/1     Running   0          2m21s
```

## 步骤四：创建Trigger，给Broker增加订阅者

Trigger表明了想要订阅某些事件的愿望。我们使用Trigger将服务`event-display`订阅到默认的Broker，它将会把发送到Broker的消息打印到日志中。

我们先来看一下`trigger1.yaml`的内容，这里描述了Trigger的配置信息，运行命令：
```text
cat trigger1.yaml
```

期待输出：
```
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
```

可以看到，它的`spec`中的`subscriber`描述了一个订阅者，具体到这里，是`event-display`服务。

使用下面命令创建Trigger `mytrigger`，运行命令：
```text
kubectl apply -f trigger1.yaml
```

期待输出：
```
trigger.eventing.knative.dev/mytrigger created
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

## 步骤五：检查event-display的日志

下面命令将列出所有运行的Pod，观察`event-display`应用所在的Pod已经开始运行，运行命令：
```
kubectl get pods
```

期待输出：
```
NAME                                              READY   STATUS    RESTARTS   AGE
default-broker-filter-798df8bc75-77m2r            1/1     Running   0          4m32s
default-broker-ingress-5fbb869648-q4xzb           1/1     Running   0          4m32s
event-display-46hhp-deployment-597487d855-dm77n   2/2     Running   0          19s
heartbeats-sender-dhnz8-569967d749-8wbwt          1/1     Running   0          3m36s
```

查看`event-display`的日志，运行命令：
```
kubectl logs -f $(kubectl get pods --selector=serving.knative.dev/configuration=event-display --output=jsonpath="{.items..metadata.name}") user-container
```

能看到日志显示的CloudEvent标准消息如下面所示：
```
_  CloudEvent: valid _
Context Attributes,
  SpecVersion: 0.2
  Type: dev.knative.eventing.samples.heartbeat
  Source: https://github.com/knative/eventing-sources/cmd/heartbeats/#default/heartbeats
  ID: 5fff8cd4-96c5-4fd6-b116-2a96977791e2
  Time: 2019-06-20T16:04:08.921707135Z
  ContentType: application/json
  Extensions:
    beats: true
    heart: yes
    knativehistory: default-broker-tp97m-channel-znkp9.default.svc.cluster.local
    the: 42
Transport Context,
  URI: /
  Host: event-display.default.svc.cluster.local
  Method: POST
Data,
  {
    "id": 26,
    "label": ""
  }
```
心跳事件消息已经被打印出来，这说明了`heartbeats-sender`创建后，产生的心跳事件消息，已经被默认Broker接受，并转发给`event-display`，`event-display`接收消息并打印在日志中

观察完毕，使用`ctrl + c`结束进程。

如果要继续下一个实验，则不必任何清理工作，继续 [exercise 4](./exercise-4.md).

