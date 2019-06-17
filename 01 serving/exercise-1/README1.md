## Setup: Install Istio and Knative on Your Cluster

Knative is currently built on top of both Kubernetes and Istio.
If you want to learn more about Kubernetes or Istio, you can check out the
labs [Kube101](https://github.com/IBM/kube101/tree/master/workshop) and
[Istio101](https://github.com/IBM/istio101/tree/master/workshop).
When you install Knative on IKS, it will install Istio for you
automatically.

### Install with IBM Kuberentes Cluster Command Line

1. Login

```
export KUBECONFIG=/Users/Daisy/.bluemix/plugins/container-service/clusters/knativesh-guoyc/kube-config-syd01-knativesh-guoyc.yml
```

2. Install
```
ibmcloud ks cluster-addon-enable knative --cluster mycluster
```

3. Enable Istio auto enjection

```
kubectl label namespace default istio-injection=enabled
```

4. Enable logging on every node

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

5. Uninstall
```
ibmcloud ks cluster-addon-disable knative --cluster mycluster
ibmcloud ks cluster-addon-disable istio --cluster mycluster
```