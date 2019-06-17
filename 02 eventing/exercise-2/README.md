## Setup: Create Channel and Subscription

We use `GithubSource` as the example. We will create a Addressable object to receive the event message and print it in logs.


### Step 1. Install Istio

1. Enter the following commands to install the credential:
```
kubectl apply -f githubsecret.yaml
```

2. Enter the following commands to install the event display service:
```
kubectl apply -f service.yaml
```

Check the service is ready by:
```
kubectl get ksvc
```

3. Enter the following commands to install github source:
```
kubectl apply -f github-source.yaml
```
Check the github source by:
```
k get githubsource
```
4. Understand your event system:

- A webhook is created in github repository. The call back service is a Knative Service.

Check the webhook call back service is:
```
$ k get ksvc
NAME                       DOMAIN                                                                          LATESTCREATED                    LATESTREADY                      READY     REASON
event-display              event-display-test.knative-guoyc.au-syd.containers.appdomain.cloud              event-display-4pvpl              event-display-4pvpl              True
githubsourcesample-mtz4r   githubsourcesample-mtz4r-test.knative-guoyc.au-syd.containers.appdomain.cloud   githubsourcesample-mtz4r-n9nlb   githubsourcesample-mtz4r-n9nlb   True
```

- The call back service will forward the CloudEvent message from Github repo to event-display service.
```
$ watch kubectl get pods
```
When event-display pod starts, check the log:
```
$ k logs event-display-4pvpl 
```