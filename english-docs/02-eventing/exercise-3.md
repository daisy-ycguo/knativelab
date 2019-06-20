# Add Filter to Trigger

We add another event source `CronJobs` which will also send event messages to default broker. We use Filter in Trigger to subscribe only a specific type of event messages.

## Step 1. Create another event source CronJobs

Create another event source `cronjobs` by:

```text
$ kubectl apply -f cronjob.yaml
cronjobsource.sources.eventing.knative.dev/cronjobs created
$ kubectl get CronJobSource
NAME       AGE
cronjobs   23s
```

Check the logs of `event-display`, you can see that both messages from `heartbeats` and `cronjob`:

```text
$ kubectl logs -f event-display-w2xvz-deployment-78569995c5-vr868 user-container
```

Event message from `cronjob`:

```text
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.2
  type: dev.knative.cronjob.event
  source: /apis/v1/namespaces/default/cronjobsources/cronjobs
  id: b611a8c8-0966-4f91-a4d7-ec4add50da7a
  time: 2019-06-18T10:59:00.000387176Z
  contenttype: application/json
Extensions,
  knativehistory: default-broker-dtszb-channel-vxw4k.default.svc.cluster.local
Data,
  {
    "message": "Hello world!"
  }
```

Terminate this process by `ctrl+c`.

Delete mytrigger by:

```text
$ kubectl delete -f trigger1.yaml
trigger.eventing.knative.dev "mytrigger" deleted
```

## Step 2. Define filter in trigger

Check a filter to the trigger `mytrigger` yaml file:

```text
$ cat trigger2.yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  filter:
    sourceAndType:
      type: dev.knative.cronjob.event
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
```

Create a new `mytrigger` with filter by applying the new version of yaml file:

```text
$ kubectl apply -f trigger2.yaml
trigger.eventing.knative.dev/mytrigger created.
```

Check the new version of `mytrigger` that filter has been configured:

```text
$ kubectl get trigger mytrigger -o yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"eventing.knative.dev/v1alpha1","kind":"Trigger","metadata":{"annotations":{},"name":"mytrigger","namespace":"default"},"spec":{"filter":{"sourceAndType":{"type":"dev.knative.cronjob.event"}},"subscriber":{"ref":{"apiVersion":"serving.knative.dev/v1alpha1","kind":"Service","name":"event-display"}}}}
  creationTimestamp: 2019-06-18T11:05:06Z
  generation: 1
  name: mytrigger
  namespace: default
  resourceVersion: "26695"
  selfLink: /apis/eventing.knative.dev/v1alpha1/namespaces/default/triggers/mytrigger
  uid: ee38938a-91b8-11e9-9c6b-4e0b3deb5d31
spec:
  broker: default
  filter:
    sourceAndType:
      type: dev.knative.cronjob.event
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-display
status:
  conditions:
  - lastTransitionTime: 2019-06-18T11:05:06Z
    status: "True"
    type: Broker
  - lastTransitionTime: 2019-06-18T11:05:07Z
    status: "True"
    type: Ready
  - lastTransitionTime: 2019-06-18T11:05:07Z
    status: "True"
    type: Subscribed
  subscriberURI: http://event-display.default.svc.cluster.local/
```

Check the logs of `event-display`, you can see that only messages from `cronjob` now:

```text
$ kubectl logs -f event-display-w2xvz-deployment-78569995c5-vr868 user-container
```

