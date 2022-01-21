#!/bin/bash
cd /root/
curl https://get.helm.sh/helm-v3.7.2-linux-amd64.tar.gz -o helm.tar.gz
tar -xf helm.tar.gz
mv linux-amd64/helm /root/helm
git clone https://github.com/obsidiandynamics/kafdrop && cd kafdrop

../helm upgrade -i kafdrop-cp4na chart --set kafka.brokerConnect=iaf-system-kafka-bootstrap.network-orchestration.svc.cluster.local:9092 --set server.servlet.contextPath="/"
oc expose svc kafdrop-cp4na

../helm upgrade -i kafdrop chart --set kafka.brokerConnect=mano-kafka-cluster-bootstrap.kafka-cluster-operator.svc.cluster.local:9092 --set server.servlet.contextPath="/" --set service.nodePort="30901"
oc expose svc kafdrop