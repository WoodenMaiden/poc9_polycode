#!/bin/env bash
set -e

red=$(tput setaf 1)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
normal=$(tput sgr0)

# This script is used to initialize the environment

function exists {
    echo "Checking dependencies: $@"
    for (( i=1; i<=$#; i++))
    {
        eval cmd=\$$i
        if ! command -v "$cmd" &> /dev/null
        then
            echo "$red$cmd could not be found$normal"
            exit 1
        fi
    }
}


# Install dependencies
exists npm minikube kubectl cfssl cfssljson

# Start minikube
if [ ! $(minikube status | grep -c "Running") -eq 1 ]
then
    minikube start
fi

eval $(minikube -p minikube docker-env)

echo "${yellow}🔨 Building apps$normal"
npx nx build hello-consumer &
npx nx build hello-provider &
wait

echo "${yellow}🔨 Building docker images$normal"
docker build -f apps/hello-consumer/Dockerfile -t hello-consumer . &
docker build -f apps/hello-provider/Dockerfile -t hello-provider . &
wait

echo "${yellow}🤫 Deploying secrets$normal"
# kubectl apply -f apps/vault/namespace.json
kubectl apply -f apps/misc/secrets/redis_secrets.json
kubectl apply -f apps/misc/secrets/jwt_secrets.json


echo "${yellow}🖥️ Deploying the app $normal"
kubectl apply -f ./apps/kubeview/kubeview.yaml &
find . -name "service.json" -exec kubectl apply -f {} \; 
find . -name deployment.json -exec kubectl apply -f {} \; 

wait

url="$(minikube service hello-consumer-service --url)"
echo "🚀 ${green}App ready! Use it with the following commands$normal"
echo "curl --location --request POST '$url/api/signup' \
--header 'Content-Type: application/json' \
--data-raw '{\"username\": \"Yann\", \"password\": \"password\"}'"

echo "curl --location --request GET '$url/api/hello' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <token you got previously>'"

echo "Run the following command to get an acess token to Consul: kubectl get secrets/consul-bootstrap-acl-token --template='{{.data.token | base64decode }}'"
echo "Run the following command to map Consul to your local machine: kubectl port-forward -n consul service/consul-ui 8080:443 --address 0.0.0.0"
echo "Kubeview is also available on your browser at $(minikube service kubeview --url) to have an overview of the cluster"