# Understand Knative Concepts

## Look into Knative Configuration

```text
kubectl get configuration
```

## Look into Knative Revision

```text
$ kubectl get revision
NAME                SERVICE NAME                GENERATION   READY     REASON
fib-knative-xk4xc   fib-knative-xk4xc-service   1            True
```

## Look into Knative Route

```text
k get route
NAME          DOMAIN                                                                     READY     REASON
fib-knative   fib-knative-knativelab.knativesh-guoyc.au-syd.containers.appdomain.cloud   True
```

Continue on to [exercise 4](./exercise-4.md).

