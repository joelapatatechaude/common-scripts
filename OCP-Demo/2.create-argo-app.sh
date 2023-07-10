#!/bin/bash
source ~/.aws/route53
source ./env.sh
source <(curl -s https://raw.githubusercontent.com/joelapatatechaude/common-scripts/main/OCP-Demo/2.functions-create-argo-app.sh)
CONTEXT=admin
PROJECT=default

MYDIR=$MYDIR ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME create_argo_cluster
sleep 1

ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME KUBECONFIG=~/.aws/gitops-kubeconfig create_app_project
sleep 1

KUBECONFIG=~/.aws/gitops-kubeconfig deploy_app
