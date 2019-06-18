## Setup: Create Broker and Trigger

We use `GithubSource` as the example. We will create a broker and a subscription.

Events are sent to the Broker’s ingress and are then sent to any subscribers that are interested in that event.

### Step 0. Check the default channel configuration (optional)

There are a few channel provisioner pre-installed in Knative. You can check all pre-installed channel provisioner by:
```
$ kubectl get ClusterChannelProvisioner -n knative-eventing
NAME                READY     REASON    AGE
in-memory           True                1h
in-memory-channel   True                1h
```

There is a default channel configuration specified in the ConfigMap named `default-channel-webhook` in the `knative-eventing` namespace. This ConfigMap may specify a cluster-wide default channel provisioner and namespace-specific channel provisioners.

```
$ k get configmap default-channel-webhook -n knative-eventing -o jsonpath='{.data}'
map[default-channel-config:clusterdefault:
  apiversion: eventing.knative.dev/v1alpha1
  kind: ClusterChannelProvisioner
  name: in-memory
namespacedefaults:
  some-namespace:
    apiversion: eventing.knative.dev/v1alpha1
    kind: ClusterChannelProvisioner
    name: some-other-provisioner
```
In this ConfigMap, we can see the cluster-wide default channel provisioner is set to `in-memory`.

### Step 1. Create a default broker

Enter the following commands:
```
$ kubectl label namespace default knative-eventing-injection=enabled
namespace/default labeled
```

Check the default broker is created:
```
$ kubectl get broker
NAME      READY     REASON    HOSTNAME                                   AGE
default   True                default-broker.default.svc.cluster.local   14s
```

```
$ k get broker default -o yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Broker
metadata:
  creationTimestamp: 2019-06-18T09:36:13Z
  generation: 1
  labels:
    eventing.knative.dev/namespaceInjected: "true"
  name: default
  namespace: default
  resourceVersion: "16855"
  selfLink: /apis/eventing.knative.dev/v1alpha1/namespaces/default/brokers/default
  uid: 83792b80-91ac-11e9-ae97-72b4e0ade7ac
spec: {}
status:
  address:
    hostname: default-broker.default.svc.cluster.local
  conditions:
  - lastTransitionTime: 2019-06-18T09:36:15Z
    status: "True"
    type: Addressable
  - lastTransitionTime: 2019-06-18T09:36:22Z
    status: "True"
    type: FilterReady
  - lastTransitionTime: 2019-06-18T09:36:16Z
    status: "True"
    type: IngressChannelReady
  - lastTransitionTime: 2019-06-18T09:36:25Z
    status: "True"
    type: IngressReady
  - lastTransitionTime: 2019-06-18T09:36:15Z
    status: "True"
    type: IngressSubscriptionReady
  - lastTransitionTime: 2019-06-18T09:36:25Z
    status: "True"
    type: Ready
  - lastTransitionTime: 2019-06-18T09:36:14Z
    status: "True"
    type: TriggerChannelReady
```

### Step 2. Create a heartbeats event source

Now we create a heartbeats event source, which will generate event message in a fixed interval to the default broker.

Check the configuration of ContainerSource `heartbeats-sender`. Note the `sink` is configured to Broker `default`.

```
$ cat heartbeats.yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ContainerSource
metadata:
  name: heartbeats-sender
spec:
  image: docker.io/daisyycguo/heartbeats-6790335e994243a8d3f53b967cdd6398
  sink:
    apiVersion: eventing.knative.dev/v1alpha1
    kind: Broker
    name: default
  args:
    - --period=1
  env:
    - name: POD_NAME
      value: "heartbeats"
    - name: POD_NAMESPACE
      value: "default"daisyyings-mbp:brokertrigger
```

Create the ContainerSource `heartbeats-sender` by:
```
$ kubectl apply -f heartbeats.yaml
containersource.sources.eventing.knative.dev/heartbeats-sender created
```

Check the ContainerSource `heartbeats-sender` is created by:
```
$ kubectl get ContainerSource
NAME                AGE
heartbeats-sender   2m
```

### Step 3. Create a trigger to add a subscriber to the broker.

A Trigger represents a desire to subscribe to events from a specific Broker. We will use the service `event-display` to subscribe to the default broker. You will be able to see the event messages sent to broker.

```
$ cat trigger1.yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: Trigger
metadata:
  name: mytrigger
spec:
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1alpha1
      kind: Service
      name: event-displaydaisyyings-mbp:brokertrigger
```

Create the trigger by:
```
$ kubectl apply -f trigger1.yaml
trigger.eventing.knative.dev/mytrigger created
```

Check the trigger is created by:
```
$ kubectl get trigger
NAME        READY     REASON    BROKER    SUBSCRIBER_URI                                    AGE
mytrigger   True                default   http://event-display.default.svc.cluster.local/   29s
```

Check the logs of `event-display`, you can see that both messages from `heartbeats` and `cronjob`:
```
$ kubectl logs -f event-display-w2xvz-deployment-78569995c5-vr868 user-container
☁️  cloudevents.Event
Validation: valid
Context Attributes,
  specversion: 0.2
  type: dev.knative.eventing.samples.heartbeat
  source: https://github.com/knative/eventing-sources/cmd/heartbeats/#default/heartbeats
  id: f073a7c0-5a52-494b-bcd9-2ee59e2091f5
  time: 2019-06-18T10:55:44.21137922Z
  contenttype: application/json
Extensions,
  beats: true
  heart: yes
  knativehistory: default-broker-dtszb-channel-vxw4k.default.svc.cluster.local
  the: 42
Data,
  {
    "id": 3,
    "label": ""
  }
```
Terminate this process by `ctrl+c`.

### Step 4. Create another event source CronJobs

Create another event source `cronjobs` by:

```
$ kubectl apply -f cronjob.yaml
cronjobsource.sources.eventing.knative.dev/cronjobs created
$ kubectl get CronJobSource
NAME       AGE
cronjobs   23s
```

Check the logs of `event-display`, you can see that both messages from `heartbeats` and `cronjob`:
```
$ kubectl logs -f event-display-w2xvz-deployment-78569995c5-vr868 user-container
```
Event message from `cronjob`:
```
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
```
$ kubectl delete -f trigger1.yaml
trigger.eventing.knative.dev "mytrigger" deleted
```

### Step 5. Define filter in trigger

Check a filter to the trigger `mytrigger` yaml file:
```
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
      name: event-displaydaisyyings-mbp:brokertrigger
```

Create a new `mytrigger` with filter by applying the new version of yaml file:
```
$ kubectl apply -f trigger2.yaml
trigger.eventing.knative.dev/mytrigger created.
```

Check the new version of `mytrigger` that filter has been configured:
```
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
```
$ kubectl logs -f event-display-w2xvz-deployment-78569995c5-vr868 user-container
```

