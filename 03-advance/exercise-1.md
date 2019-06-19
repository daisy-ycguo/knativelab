# README

1. 启动Istio自动注入（可选）

在CloudShell窗口中执行：

```text
kubectl label namespace default istio-injection=enabled
```

1. 启用fluentd日志（可选）

```text
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
```

Disable logging

```text
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready-
```

Check

```text
kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
```

