## Setup: Install Istio and Knative on Your Cluster

Knative is currently built on top of both Kubernetes and Istio.
If you want to learn more about Kubernetes or Istio, you can check out the
labs [Kube101](https://github.com/IBM/kube101/tree/master/workshop) and
[Istio101](https://github.com/IBM/istio101/tree/master/workshop).
When you install Knative on IKS, it will install Istio for you
automatically.

### Step 1. Install Istio

1. Enter the following commands to download Istio:

   ```shell
   # Download and unpack Istio
   export ISTIO_VERSION=1.1.3
   curl -L https://git.io/getLatestIstio | sh -
   cd istio-${ISTIO_VERSION}
   ```

1. Enter the following command to install the Istio CRDs first:

   ```shell
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
   ```

   If you want to delete it, using below command:
   ```shell
   for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl delete -f $i; done
   ```

   Wait a few seconds for the CRDs to be committed in the Kubernetes API-server,
   then continue with these instructions.

1. Create `istio-system` namespace

```shell
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: istio-system
  labels:
     istio-injection: disabled
EOF
```

1. Enter the following command to install Istio with automatic sidecar injection:

```shell
# A template with sidecar injection enabled.
helm template --namespace=istio-system \
  --set sidecarInjectorWebhook.enabled=true \
  --set sidecarInjectorWebhook.enableNamespacesByDefault=true \
  --set global.proxy.autoInject=disabled \
  --set global.disablePolicyChecks=true \
  --set prometheus.enabled=false \
  `# Disable mixer prometheus adapter to remove istio default metrics.` \
  --set mixer.adapters.prometheus.enabled=false \
  `# Disable mixer policy check, since in our template we set no policy.` \
  --set global.disablePolicyChecks=true \
  `# Set gateway pods to 1 to sidestep eventual consistency / readiness problems.` \
  --set gateways.istio-ingressgateway.autoscaleMin=1 \
  --set gateways.istio-ingressgateway.autoscaleMax=1 \
  --set gateways.istio-ingressgateway.resources.requests.cpu=500m \
  --set gateways.istio-ingressgateway.resources.requests.memory=256Mi \
  `# More pilot replicas for better scale` \
  --set pilot.autoscaleMin=2 \
  `# Set pilot trace sampling to 100%` \
  --set pilot.traceSampling=100 \
  install/kubernetes/helm/istio \
  > ./istio.yaml

kubectl apply -f istio.yaml
```

### Step 2. Install Knative Serving
```
kubectl apply --selector knative.dev/crd-install=true \
--filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml
```

```
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml --selector networking.knative.dev/certificate-provider!=cert-manager \
--filename https://github.com/knative/build/releases/download/v0.6.0/build.yaml \
--filename https://github.com/knative/eventing/releases/download/v0.6.0/release.yaml \
--filename https://github.com/knative/eventing-sources/releases/download/v0.6.0/eventing-sources.yaml \
--filename https://github.com/knative/serving/releases/download/v0.6.0/monitoring.yaml \
--filename https://raw.githubusercontent.com/knative/serving/v0.6.0/third_party/config/build/clusterrole.yaml
```

To delete Knative....
```
kubectl delete --filename https://github.com/knative/serving/releases/download/v0.6.0/serving.yaml \
--filename https://github.com/knative/build/releases/download/v0.6.0/build.yaml \
--filename https://github.com/knative/eventing/releases/download/v0.6.0/release.yaml \
--filename https://github.com/knative/eventing-sources/releases/download/v0.6.0/eventing-sources.yaml \
--filename https://github.com/knative/serving/releases/download/v0.6.0/monitoring.yaml \
--filename https://raw.githubusercontent.com/knative/serving/v0.6.0/third_party/config/build/clusterrole.yaml
```

### Step 3. Verify
   The install process may take a minute or two. To know when it's done you
   can run two commands - first see if the Istio and Knative namespaces
   are there:

   ```
   kubectl get namespace
   ```

   and you should see something like:

   ```
   NAME                 STATUS   AGE
   default              Active   7d18h
   ibm-cert-store       Active   7d18h
   ibm-system           Active   7d18h
   istio-system         Active   7d17h
   knative-build        Active   7d17h
   knative-eventing     Active   7d17h
   knative-monitoring   Active   7d17h
   knative-serving      Active   7d17h
   knative-sources      Active   7d17h
   kube-public          Active   7d18h
   kube-system          Active   7d18h
   ```

   Notice the `istio-system` namespace, and the `knative-...` namespaces.

   Once the namespaces are there, check to see if all of the Istio and
   Knative pods are running correctly:

   ```
   kubectl get pods --namespace istio-system
   kubectl get pods --namespace knative-serving
   kubectl get pods --namespace knative-eventing
   kubectl get pods --namespace knative-sources
   ```

   You could check the pods in all of the Knative namespaces, but for this
   workshop only "knative-serving", "knative-eventing" and "knative-sources" are required.
   

   Example Ouput:

   ```
   NAME                                      READY     STATUS    RESTARTS   AGE
   activator-7587c7475b-x5wrk                2/2       Running   0          17h
   autoscaler-5bf6cfd9bc-bf5xg               2/2       Running   0          17h
   controller-dc64767cf-5vtk8                1/1       Running   0          17h
   networking-certmanager-5668bdd495-zxnrj   1/1       Running   0          17h
   networking-istio-fc9c659-g7r2l            1/1       Running   0          17h
   webhook-5fdcd4499d-hcrqb                  1/1       Running   0          17h
   ```

   If all of the pods shown are in a `Running` or `Completed` state then you should be all set.

Continue on to [exercise 2](../exercise-2/README.md).

Issue: v1.13.6+IKS