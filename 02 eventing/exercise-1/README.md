## Setup: Simple way to catch an Event

We use `GithubSource` as the example. We will create a Addressable object to receive the event message and print it in logs.


### Step 1. Create a event display service

Enter the following commands to install the event display service:
```
kubectl apply -f service.yaml
```

Check the service is ready by:
```
kubectl get ksvc
```

### Step 2. Create a githubsource

Enter the following commands to install the config map with github credential:
```
kubectl apply -f githubsecret.yaml
```


Enter the following commands to install github source:
```
kubectl apply -f github-source.yaml
```
Check the github source by:
```
k get githubsource
```

### Step 3. Understand the back end of event mechanism

- A webhook is created in github repository. The call back service is a Knative Service.

Check the webhook call back service is:
```
$ k get ksvc
NAME                       DOMAIN                                                                          LATESTCREATED                    LATESTREADY                      READY     REASON
event-display              event-display-test.knative-guoyc.au-syd.containers.appdomain.cloud              event-display-4pvpl              event-display-4pvpl              True
githubsourcesample-mtz4r   githubsourcesample-mtz4r-test.knative-guoyc.au-syd.containers.appdomain.cloud   githubsourcesample-mtz4r-n9nlb   githubsourcesample-mtz4r-n9nlb   True
```

- The call back service will forward the CloudEvent message from Github repo to event-display service.

### Step 4. Check the log

```
$ watch kubectl get pods
```

When event-display pod starts, check the log:
```
$ k logs event-display-4pvpl 
```