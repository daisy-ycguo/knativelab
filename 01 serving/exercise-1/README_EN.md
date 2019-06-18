## Install Knative

Knative is based on Kubernetes and Istio. You can install Knative with one command line on IKS.

### Install Knative with IBM Cloud CLI

1. Install with 1 command line

In your CloudShell window, input:
```
$ ibmcloud ks cluster-addon-enable knative --cluster <your_cluster_name>
Enabling add-on knative for cluster knative1-guoyc...
The istio add-on version 1.1.7 is required to enable the knative add-on. Enable istio? [y/N]> y
OK
```


2. Look into Knative after installation

List all namespaces：
```
$ kubectl get namespace
NAME                 STATUS    AGE
default              Active    30m
ibm-cert-store       Active    20m
ibm-system           Active    28m
istio-system         Active    5m20s
knative-build        Active    5m14s
knative-eventing     Active    5m14s
knative-monitoring   Active    5m14s
knative-serving      Active    5m14s
knative-sources      Active    5m14s
kube-public          Active    30m
kube-system          Active    30m
```

Check the pods under namespace `istio-system` to make sure there are no errors：
```
$ kubectl get pods -n istio-system
NAME                                     READY     STATUS    RESTARTS   AGE
cluster-local-gateway-5897bf4bdd-fr544   1/1       Running   0          4m51s
istio-citadel-6f58d87c48-b9v5f           1/1       Running   0          5m32s
istio-egressgateway-5ffbbb468-c5t6j      1/1       Running   0          5m32s
istio-galley-65bcc9b6f7-czqmp            1/1       Running   0          5m32s
istio-ingressgateway-85787c5976-2vwsp    1/1       Running   0          5m32s
istio-pilot-77d74c888-nqzbq              2/2       Running   0          5m32s
istio-policy-7f79dbbdc7-2tffd            2/2       Running   5          5m32s
istio-sidecar-injector-68c4dc865-p8r7v   1/1       Running   0          5m31s
istio-telemetry-697d4cf64-vmgzf          2/2       Running   6          5m31s
prometheus-7d6678d744-swb6q              1/1       Running   0          5m31s
```

Check the pods under namespace `knative-serving` to make sure there are no errors：
```
$ kubectl get pods -n knative-serving
NAME                                     READY     STATUS    RESTARTS   AGE
activator-54f5ff5cc7-6vrlt               2/2       Running   1          4m33s
autoscaler-6f4965c9bd-w997f              2/2       Running   0          4m33s
controller-5b9bfd9594-d9bsv              1/1       Running   0          4m33s
networking-certmanager-d8c475984-l97j8   1/1       Running   0          4m33s
networking-istio-76d4b55fd4-cf6q5        1/1       Running   0          4m33s
webhook-75bcf549-dq587                   1/1       Running   0          4m33s
```

3. Enable Istio auto injection（optional）

In your CloudShell window, input:
```
kubectl label namespace default istio-injection=enabled
```

4. Enable fluentd node exporter（optional）

In your CloudShell window, input:
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

Continue [exercise 2](../exercise-2/README.md).

5. Unistall Knative（可选）
If you want to unistall Knative and Istio, input below commands at your CloudShell window：
```
ibmcloud ks cluster-addon-disable knative --cluster mycluster
ibmcloud ks cluster-addon-disable istio --cluster mycluster
```

6. Reference
If you want to learn Kubernetes, go to [Kube101](https://github.com/IBM/kube101/tree/master/workshop)。
If you want to learn Istio, go to [Istio101](https://github.com/IBM/istio101/tree/master/workshop).