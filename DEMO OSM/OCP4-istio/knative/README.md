
## Create resources (no yaml required)
```
oc api-resources --api-group serving.knative.dev
kn service create greeter \
  --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus \
  --namespace serverless-tutorial
kn service update greeter \
  --image quay.io/rhdevelopers/knative-tutorial-greeter:latest \
  --namespace serverless-tutorial
kn service delete greeter
```
## Traffic Distribution
```
kn service create greeter \
  --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus \
  --namespace serverless-tutorial \
  --revision-name greeter-v1
kn service update greeter \
  --image quay.io/rhdevelopers/knative-tutorial-greeter:quarkus \
  --namespace serverless-tutorial \
  --revision-name greeter-v2 \
  --env MESSAGE_PREFIX=GreeterV2
kn service update greeter \
  --traffic greeter-v1=100 \
  --tag greeter-v1=current \
  --tag greeter-v2=prev \
  --tag @latest=latest
kn service update greeter --traffic greeter-v2=100
```
## Canary Releases
```
kn service update greeter \
  --traffic greeter-v1=80 \
  --traffic greeter-v2=20 \
  --traffic @latest=0
```
## Scaling
```
kn service create cpu-php \
  --namespace serverless-tutorial \
  --annotation autoscaling.knative.dev/minScale=2 \
  --annotation autoscaling.knative.dev/maxScale=5 \
  --image quay.io/f_bernal_cerpa/php-load:latest
kn service update cpu-php \
  --annotation autoscaling.knative.dev/target=50 

ab -n 2550 -c 850 -t 60 "http://cpu-php-serverless-tutorial.apps.cluster-addd.addd.example.opentlc.com/" && oc get deployment -n serverless-tutorial
```

## Utils
```
kn service list
kn service describe greeter
kn route list
kn route describe greeter
kn revision list
kn service delete greeter
oc -n knative-serving describe cm config-autoscaler
```
To change the stable-window and scale-to-zero-grace-period: `oc -n knative-serving describe cm config-autoscaler` 

