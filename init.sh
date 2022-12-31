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

echo "Building apps"
npx nx build hello-consumer
npx nx build hello-provider

echo 'Building docker images'
docker build -f apps/hello-consumer/Dockerfile -t hello-consumer .
docker build -f apps/hello-provider/Dockerfile -t hello-provider .

echo "Deploying secrets"
kubectl apply -f apps/misc/secrets/redis_secrets.json
kubectl apply -f apps/misc/secrets/jwt_secrets.json

echo "Deploying apps"

kubectl apply -f apps/redis/deployment.json
kubectl apply -f apps/redis/service.json

kubectl apply -f apps/hello-consumer/deployment.json
kubectl apply -f apps/hello-provider/deployment.json

kubectl apply -f apps/hello-consumer/service.json
kubectl apply -f apps/hello-provider/service.json


url="$(minikube service hello-consumer-service --url)"
echo "App ready! Use it with the following commands"
echo "curl --location --request POST '$url/api/signup' \
--header 'Content-Type: application/json' \
--data-raw '{\"username\": \"Yann\", \"password\": \"password\"}'"

echo "curl --location --request GET '$url/api/hello' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <token you got previously>'"
