## Monitoring and logging

### Look into knative-monitoring


```
$ kubectl get pods -n knative-monitoring
NAME                                  READY     STATUS    RESTARTS   AGE
elasticsearch-logging-0               1/1       Running   0          5h37m
elasticsearch-logging-1               1/1       Running   0          5h35m
grafana-6d8b5bc97-q5wb4               1/1       Running   0          5h37m
kibana-logging-6ccb64cbf4-7rvnh       1/1       Running   0          5h37m
kube-state-metrics-65f7898cc6-88t8g   4/4       Running   0          5h36m
node-exporter-n7xq2                   2/2       Running   0          5h37m
node-exporter-sb7bk                   2/2       Running   0          5h37m
prometheus-system-0                   1/1       Running   0          5h37m
prometheus-system-1                   1/1       Running   0          5h37m
```


### Check logs

```
kubectl proxy
```
+ Visit [Kibana UI](http://localhost:8001/api/v1/namespaces/knative-monitoring/services/kibana-logging/proxy/app/kibana) to get logs. Use `kubernetes.labels.serving_knative_dev\/revision: : "telemetrysample-configuration-00001"` to search logs of this revision. Use `kubernetes.labels.serving_knative_dev\/configuration: "telemetrysample-configuration"` to search logs of this configuration.

### Check telemetries
+ Visit [Prometheus UI](http://localhost:9090) to get metrics. Use `istio_revision_request_duration_sum{destination_configuration="telemetrysample-configuration"}` and `istio_revision_request_count{destination_configuration="telemetrysample-configuration"}` to search metrics.
+ Visit [Grafana](http://localhost:3000) to get metrics.

```
$ kubectl -n knative-monitoring port-forward $(kubectl -n knative-monitoring get pod -l app=prometheus -o jsonpath="{.items[0].metadata.name}") 9090
$ kubectl port-forward --namespace knative-monitoring $(kubectl get pods --namespace knative-monitoring --selector=app=grafana --output=jsonpath="{.items..metadata.name}") 3000
```

### Check traces

Visit [Zipkin](http://localhost:8001/api/v1/namespaces/istio-system/services/zipkin:9411/proxy/zipkin/) to get trace.

```
kubectl proxy
```
