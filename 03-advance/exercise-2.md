# 创建事件以及订阅该事件

在这个练习中，我们将使用`GithubSource`。我们会创建一个可访问的对象来接收事件消息，并把它打印到日志中。

***注意*** 下面的操作要求在目录`knativelab/src/githubsrcsample`中进行，可以在CloudShell窗口执行下面命令进入该目录：
```
cd ~/knativelab/src/githubsrcsample/
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

Knative预先安装了Github事件源类型githubsource，可以用这个事件源来监听Github上代码库中产生的事件。为了便于操作，我们统一来监听`https://github.com/guoyingc/eventsource-demo`这个代码库上的事件。每当产生了被监听的事件，Github会向Knative事件平台发送一条事件消息。

1. 配置访问凭证

为了监听这个代码库中的事件，必须取得个人访问令牌（Personal access tokens）。请向IBM工作人员询问个人访问令牌，即一个字符串。

我们将这个个人访问令牌的数据，写入`githubsecret.yaml`文件中，通过下面命名完成:

***注意***这个命令里的`000111aaabbb000000`需要替换为正确的个人访问令牌的字符串，类似于`***b8261a31bc4b***ad2b86cda0267392906***`。

```
sed -i 's/your_access_token/000111aaabbb000000/' githubsecret.yaml
```

通过`cat githubsecret.yaml`命令检查正确的个人访问令牌已经被写入githubsecret.yaml。

下面就可以应用该文件，配置访问凭证了：
```text
$ kubectl apply -f githubsecret.yaml
secret/githubsecret created
```

2. 创建Github事件源

我们先来看一下`github-source.yaml`的内容，这里描述了Github事件源的配置信息：
```text
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: GitHubSource
metadata:
  name: githubsourcesample
spec:
  eventTypes:
  - commit_comment
  ownerAndRepository: guoyingc/eventsource-demo
  accessToken:
    secretKeyRef:
      name: githubsecret
      key: accessToken
  secretToken:
    secretKeyRef:
      name: githubsecret
      key: secretToken
  sink:
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    name: event-display
```

可以看到，它的`spec`主要包含五部分内容：
- eventTypes: 监听的事件类型，这里看到监听的事件为`commit_comment`
- ownerAndRepository: 监听的代码库
- accessToken 和 secretToken: 访问所需的凭证信息
- sink: 定义了在事件源接收到事件数据后，把事件数据传送的目的地，这里可以看到是Knative服务 `event-display`，也就是我们刚才创建的服务。

通过下面命令创建事件源`githubsourcesample`:

```text
$ kubectl apply -f github-source.yaml
githubsource.sources.eventing.knative.dev/githubsourcesample created
```

检查该事件源已经被创建:

```text
$ kubectl get githubsource
NAME                 AGE
githubsourcesample   54s
```

## 步骤三：检查event-display的日志

在事件源创建后，每当一个commit_comment事件产生时，就会有一条事件消息发送给`event-display`，`event-display`将把它打印到日志中。



```text
$ watch kubectl get pods
```

When event-display pod starts, check the log:

```text
$ kubectl logs event-display-v6g49-deployment-7ff879ff4f-w7dcv user-container
```

## 步骤四：理解工作机理

- 在Github中，可以定义webhook，使得Github上的某类事件发生时，将把JSON格式的事件消息发送到该webhook上。
- Knative通过Knative Service来实现webhook的回调。
- webhook回调的服务，将把JSON格式的事件消息，转化为符合CloudEvent格式的事件消息，并转送给Sink所指向的地址。在这个例子中，就是event-display。

通过这个命令列出所有的Knative Service，其中以githubsourcesample-*为前缀的服务，这个服务的域名将会被当成Webhook注册到github中去。

```text
$ kn service list
NAME                       DOMAIN                                                                              GENERATION   AGE     CONDITIONS   READY   REASON
event-display              event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud              4            45m     3 OK / 3     True
githubsourcesample-b6f6q   githubsourcesample-b6f6q-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            3m39s   3 OK / 3     True
```
将githubsourcesample-*为前缀的服务的域名记录在环境变量中，备用：
```
export CALLBACKURL=githubsourcesample-......
```

通过这个命令，可以列出所有的webhook，在里面应该可以找到你的githubsourcesample-*的服务的域名:

***注意***这个命令里的`000111aaabbb000000`需要替换为正确的个人访问令牌的字符串，类似于`***b8261a31bc4b***ad2b86cda0267392906***`。
```
curl -u 843b8261a31bc4be7ead2b86cda0267392906c2c:x-oauth-basic https://api.github.com/repos/guoyingc/eventsource-demo/hooks | jq '.[] | {message: .config.url}' | grep $CALLBACKURL
```

如果能找到你注册的webhook，那么会输出红色高亮的消息：
```
"message": "http://githubsourcesample-b6f6q-default.knative1-guoyc.au-syd.containers.appdomain.cloud"
```

如果没有这个消息，则表明你的webhook并没有被注册进去。那么实验一定不会成功。