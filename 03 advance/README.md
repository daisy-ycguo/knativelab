3. 启动Istio自动注入（可选）

在CloudShell窗口中执行：
```
kubectl label namespace default istio-injection=enabled
```

4. 启用fluentd日志（可选）

```
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready="true"
```
Disable logging
```
kubectl label nodes --all beta.kubernetes.io/fluentd-ds-ready-
```
Check
```
kubectl get nodes --selector beta.kubernetes.io/fluentd-ds-ready=true
```
