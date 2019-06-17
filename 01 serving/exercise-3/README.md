## Understand Knative Concepts

### Look into Knative Configuration

```
kubectl get configuration fib-knative -o yaml
```

```
apiVersion: v1
items:
- apiVersion: serving.knative.dev/v1alpha1
  kind: Configuration
  metadata:
    creationTimestamp: 2019-06-06T05:41:03Z
    generation: 1
    labels:
      serving.knative.dev/route: fib-knative
      serving.knative.dev/service: fib-knative
    name: fib-knative
    namespace: knativelab
    ownerReferences:
    - apiVersion: serving.knative.dev/v1alpha1
      blockOwnerDeletion: true
      controller: true
      kind: Service
      name: fib-knative
      uid: ac41c4fa-881d-11e9-9e94-ae114792cdef
    resourceVersion: "23828"
    selfLink: /apis/serving.knative.dev/v1alpha1/namespaces/knativelab/configurations/fib-knative
    uid: ac57940a-881d-11e9-b2ce-7aad3abc738d
  spec:
    revisionTemplate:
      metadata:
        creationTimestamp: null
      spec:
        container:
          image: docker.io/ibmcom/fib-knative
          name: ""
          resources:
            requests:
              cpu: 400m
        timeoutSeconds: 300
  status:
    conditions:
    - lastTransitionTime: 2019-06-06T05:41:22Z
      status: "True"
      type: Ready
    latestCreatedRevisionName: fib-knative-xk4xc
    latestReadyRevisionName: fib-knative-xk4xc
    observedGeneration: 1
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
```
### Look into Knative Revision

```
$ kubectl get revision
NAME                SERVICE NAME                GENERATION   READY     REASON
fib-knative-xk4xc   fib-knative-xk4xc-service   1            True
```


### Look into Knative Route

```
k get route
NAME          DOMAIN                                                                     READY     REASON
fib-knative   fib-knative-knativelab.knativesh-guoyc.au-syd.containers.appdomain.cloud   True
```

Continue on to [exercise 1](../exercise-1/README.md).
