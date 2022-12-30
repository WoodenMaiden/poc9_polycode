#!/bin/env bash

set -e

# This script is used to initialize the environment

# Install dependencies
# node
if ! command -v npm &> /dev/null
then
    echo "npm could not be found"
    exit
fi

# minikube
if ! command -v minikube &> /dev/null
then
    echo "minikube could not be found"
    exit
fi

# kubectl
if ! command -v kubectl &> /dev/null
then
    echo "kubectl could not be found"
    exit
fi

# Start minikube
if [ ! $(minikube status | grep -c "Running") -eq 1 ]
then
    minikube start
fi

eval $(minikube -p minikube docker-env)

npx nx build hello-consumer
npx nx build hello-provider

docker build -f apps/hello-consumer/Dockerfile -t hello-consumer .
docker build -f apps/hello-provider/Dockerfile -t hello-provider .

kubectl apply -f apps/hello-consumer/deployment.json
kubectl apply -f apps/hello-provider/deployment.json
kubectl apply -f apps/hello-consumer/service.json
kubectl apply -f apps/hello-provider/service.json


echo "App ready! Use it with GET $(minikube service hello-consumer-service --url)"