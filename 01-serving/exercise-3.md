# 理解并观察 Knative 中的元素

## 前提

* 第一个Knative Service `fib-service`被创建出来；

## 步骤一：查看Knative Configuration

```text
$ kubectl get configuration
NAME          LATESTCREATED       LATESTREADY         READY   REASON
fib-knative   fib-knative-kv9n4   fib-knative-kv9n4   True
```

## 步骤二：查看Knative Revision

```text
$ kubectl get revision
NAME                SERVICE NAME                GENERATION   READY     REASON
fib-knative-xk4xc   fib-knative-xk4xc-service   1            True
```

## 步骤三：查看Knative Route

```text
$ kubectl get route
NAME          DOMAIN                                                                     READY     REASON
fib-knative   fib-knative-knativelab.knativesh-guoyc.au-syd.containers.appdomain.cloud   True
```

## 步骤四：删除Knative服务

我们将通过其他方法再次创建该服务，这里我们先把它删掉。

   ```text
    $ kn service delete fib-knative
    Service 'fib-knative' successfully deleted in namespace 'default'.
   ```

继续 [exercise 4](./exercise-4.md).

