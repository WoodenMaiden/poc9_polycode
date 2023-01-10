# Poc9

This is a proof of concept for a zero trust kubernetes cluster managed with Consul 

## Dependencies: 

* bash
* kubectl
* k3d
* docker
* node

## Set up cluster
    
```bash
# This WILL take time to complete grab a coffee ☕
./init.sh

# You might want to wait a little bit longer so the ingress is ready
```

## API Routes

| Route | Body | Headers | Description |
| :---: | :---: | :---: | :---: |
| ``GET /api/ping`` |❎|❎| Pong |
| ``POST /api/signup`` |``{"username": string, "password": string}``|❎| Signup and get an access token |
| ``POST /api/login`` |``{"username": string, "password": string}``|❎| Login and get an access token |
| ``GET /api/hello`` |❎|Authorization| Get greeted by the internet |

