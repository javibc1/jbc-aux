# ServiceMesh
First move into ServiceMesh directory `cd servicemesh` and install Service Mesh (operators configured for OCP 4.6) `oc apply -Rf ./install-operators` and check that operators are installed, pods in running state in projects openshift-operators and openshift-operators-redhat `oc get pods -n openshift-operators && oc get pods -n openshift-operators-redhat`

Next step is to install a istio-cluster `oc apply -f ./install-servicemesh` and wait a bit for all pods to deploy `oc get smcp -n istio-system`. Once pods are running you can deploy bookinfo or recommendation apps by the following commands:

To install the applications:
- Bookinfo: `oc apply -f ./app-bookinfo -n bookinfo`
- Recommendation: `oc apply -Rf ./app-recommendation -n recommendation`
  
To apply different Istio configurations for each application, apply the Gateway and Destination Rules for each project and apply the VirtualService you want to test

# Knative
First install Knative operator and generate a knative-serving default instance in knative-serving namespace and check the available resources `oc api-resources --api-group serving.knative.dev` 

## Create resources (no yaml required)
```
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

ab -n 2550 -c 850 -t 60 "http://cpu-php-serverless-tutorial.apps.cluster-34d8.34d8.example.opentlc.com/" && oc get deployment -n serverless-tutorial
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

# Kustomize
We can test kustomize by `kubectl apply -k ./kustomize/environments/dev/` in DEV namespace and `kubectl apply -k ./kustomize/environments/pro/` in PRO namespace, we can see 2 replicas in DEV and 4 replicas in PRO. In PRO we also passed an environment variable to change the message we get. Aditionally, we can uncomment the images block in ./kustomize/environments/dev/kustomization.yaml and change also the image and tag being used by the deployment.

We can also get the definition of the modified yaml `kubectl kustomize kustomize/environments/dev/` or using the kustomize CLI `kustomize build kustomize/environments/dev/`

# VPA
For testing the VPA, first install the VerticalPodAutoscaler Operator, then you can apply the vpa/vpa-cr.yaml `oc apply -f vpa/vpa-cr.yaml` that should refer to the application we want the VPA to control. We can deploy a simple httpd from samples in developer console. We can get the VPA recommendation running the command `oc get vpa vpa-recommender --output yaml`.

# HPA
To test the Horizontal Pod Autoscaler using memory metrics, first make sure to create the mem-hpa/limits.yaml. Then we have to deploy a DeploymentConfig (we can do it using the Developer Console, using the image quay.io/f_bernal_cerpa/memory-php:latest, make sure that you select 8080 as TargetPort). After the deployment is created, we can deploy in the same namespace that the application the mem-hpa/mem-hpa.yaml `oc apply -f mem-hpa/mem-hpa.yaml` and after a couple of minutes the HPA should be registering memory metrics `oc get hpa`. 

# Automate Volume Expander
First install the Automate Volume Expander Operator in the console, then create the pvc and deploy in volume-expander. Inside the terminal download files into the /data folder, where pvc is configured. For example `wget https://www.managementsolutions.com/sites/default/files/publicaciones/eng/machine-learning.pdf` and then copy the file multiple times to reach the storage limit configured. After a couple of minutes the pvc would expand and the pod would restart with the new storage capacity but maintaining the previous files.