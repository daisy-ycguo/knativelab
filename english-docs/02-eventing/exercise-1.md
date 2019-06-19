# Create an Event and subscribe it

We use `GithubSource` as the example. We will create a Addressable object to receive the event message and print it in logs.

_**Note**_ Go to `knativelab/src/githubsrcsample` to do the following actions.

## Step 1. Create a event display service

Enter the following commands to install the event display service:

```text
$ kn service create --image docker.io/daisyycguo/event_display-bb44423e21d22fe93666b961f6cfb013 event-display
Service 'event-display' successfully created in namespace 'default'.
```

Check the service is ready by:

```text
$ kn service list
NAME            DOMAIN                                                                   GENERATION   AGE   CONDITIONS   READY   REASON
event-display   event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            32s   3 OK / 3     True
```

## Step 2. Create a githubsource

Enter the following commands to install the config map with github credential:

```text
$ kubectl apply -f githubsecret.yaml
secret/githubsecret created
```

Enter the following commands to install github source:

```text
$ kubectl apply -f github-source.yaml
githubsource.sources.eventing.knative.dev/githubsourcesample created
```

Check the github source by:

```text
$ kubectl get githubsource
NAME                 AGE
githubsourcesample   54s
```

## Step 3. Understand the back end of event mechanism

* A webhook is created in github repository. The call back service is a Knative Service.

Check the webhook call back service is:

```text
$ kn service list
NAME                       DOMAIN                                                                              GENERATION   AGE     CONDITIONS   READY   REASON
event-display              event-display-default.knative1-guoyc.au-syd.containers.appdomain.cloud              4            45m     3 OK / 3     True
githubsourcesample-b6f6q   githubsourcesample-b6f6q-default.knative1-guoyc.au-syd.containers.appdomain.cloud   1            3m39s   3 OK / 3     True
```

* The call back service will forward the CloudEvent message from Github repo to event-display service.

## Step 4. Check the log

```text
$ watch kubectl get pods
```

When event-display pod starts, check the log:

```text
$ k logs event-display-4pvpl
```

