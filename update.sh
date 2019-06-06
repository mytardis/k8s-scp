#!/bin/sh

# Build
docker build . --squash -t mytardis/k8s-scp:latest

# Push
docker push mytardis/k8s-scp:latest

# Update
kubectl -n mytardis scale deployment.apps/scp --replicas=0
sleep 3
kubectl -n mytardis scale deployment.apps/scp --replicas=2

# Watch
watch kubectl -n mytardis get pods
