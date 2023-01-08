#!/bin/env bash
set -e

red=$(tput setaf 1)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
normal=$(tput sgr0)
blue=$(tput setaf 4)

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
exists npm k3d kubectl docker 

# Start minikube
if [ ! $(k3d cluster list | grep -c "poc9") -eq 1 ]
then
    k3d cluster create -c k3d.yml poc9
fi

echo "${yellow}🔨 Building apps$normal"
npx nx build hello-consumer &
npx nx build hello-provider &
wait

echo "${yellow}🔨 Building docker images$normal"
docker build -f apps/hello-consumer/Dockerfile -t hello-consumer . &
docker build -f apps/hello-provider/Dockerfile -t hello-provider . &
wait

k3d image import hello-consumer -c poc9
k3d image import hello-provider -c poc9

echo "${yellow}🤫 Deploying secrets$normal"
kubectl apply -f apps/misc/secrets/redis_secrets.json
kubectl apply -f apps/misc/secrets/jwt_secrets.json

kubectl apply -f apps/consul/consul.yaml
echo "${yellow}😴 Waiting for consul to be ready$normal"
kubectl wait --for=condition=available deployment/consul-connect-injector --timeout=1200s

echo "${yellow}🔌 Applying consul Intents$normal"
find apps/consul/policies -exec kubectl apply -f {} \;

echo "${yellow}🖥️ Deploying the app $normal"
kubectl apply -f ./apps/kubeview/kubeview.yaml &
kubectl apply -f ./apps/consul/ingress.json &
find . -name "service*.json" -exec kubectl apply -f {} \; &
find . -name deployment.json -exec kubectl apply -f {} \; &

wait

url="http://localhost:8080"
echo "🚀 ${green}App ready! Use it with the following commands$normal"
echo "curl --location --header \"Host: hello-consumer-service.ingress.consul\" --request POST '$url/api/signup' \
--header 'Content-Type: application/json' \
--data-raw '{\"username\": \"Yann\", \"password\": \"password\"}'"

echo "curl --header \"Host: hello-consumer-service.ingress.consul\" --location --request GET '$url/api/hello' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer <token you got previously>'"

echo "Run the following command to get an acess token to Consul: kubectl get secrets/consul-bootstrap-acl-token --template='{{.data.token | base64decode }}'"
echo "Run the following command to map Consul to your local machine: kubectl port-forward service/consul-ui 8082:443 --address 0.0.0.0"
echo "Kubeview is also available on your browser, run kubectl port-forward service/kubeview 8081:80 --address 0.0.0.0"