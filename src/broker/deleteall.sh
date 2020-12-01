kubectl delete -f trigger.yaml
kubectl delete -f heartbeats.yaml
kubectl delete -f ../cronjob/service.yaml
kubectl label namespace default knative-eventing-injection-
kubectl delete broker default
