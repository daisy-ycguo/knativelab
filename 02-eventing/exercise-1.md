# 创建事件以及订阅该事件

在这个练习中，我们将使用`GithubSource`。我们会创建一个可访问的对象来接收事件消息，并把它打印到日志中。

***注意*** 下面的操作需要在目录`knativelab/src/githubsrcsample`中进行，执行下面命令进入该目录：
```
cd ../githubsrcsample/
```

## 步骤一：创建接收事件消息的服务

由于Knative Service自带一个域名可以访问，所以我们创建一个Knative Service作为可访问的对象，来接受事件消息。输入下面的命令，创建`event-display`服务：

```text
$ kn service create --image docker.io/daisyycguo/event_display-bb44423e21d22fe93666b961f6cfb013 event-display
Service 'event-display' successfully created in namespace 'default'.
```

通过下面命令检查该服务已经创建完成，`READY`那栏显示 `OK`，`REASON`那栏显示`True`。如果还没有，请等待一段时间:

```text
$ kn service list
NAME            DOMAIN                                                                   GENERATION   AGE   CONDITIONS   READY   REASON
event-display   event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            32s   3 OK / 3     True
```

## 步骤二：创建Github事件源

Enter the following commands to install the config map with github credential:

```text
$ kubectl apply -f githubsecret.yaml
secret/githubsecret created
```

Enter the following commands to install github source:

```text
$ kubectl apply -f github-source.yaml
githubsource.sources.eventing.knative.dev/githubsourcesample created
```

Check the github source by:

```text
$ kubectl get githubsource
NAME                 AGE
githubsourcesample   54s
```

## Step 3. Understand the back end of event mechanism

* A webhook is created in github repository. The call back service is a Knative Service.

Check the webhook call back service is:

```text
$ kn service list
NAME                       DOMAIN                                                                              GENERATION   AGE     CONDITIONS   READY   REASON
event-display              event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud              4            45m     3 OK / 3     True
githubsourcesample-b6f6q   githubsourcesample-b6f6q-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            3m39s   3 OK / 3     True
```

* The call back service will forward the CloudEvent message from Github repo to event-display service.

## Step 4. Check the log

```text
$ watch kubectl get pods
```

When event-display pod starts, check the log:

```text
$ kubectl logs event-display-4pvpl
```

