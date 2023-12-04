#!/bin/bash
source ~/.aws/route53
source ./env-local.sh
source ~/.aws/github
source ~/.aws/github-webhook
source <(curl -s https://raw.githubusercontent.com/joelapatatechaude/common-scripts/main/OCP-Demo/2.functions-create-argo-app.sh)
CONTEXT=admin
PROJECT=default

private_repo_creds
private_repo

manual_webhook

MYDIR=$MYDIR ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME create_argo_cluster
sleep 1

ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME KUBECONFIG=$HUB_KUBECONFIG create_app_project
sleep 1

KUBECONFIG=$HUB_KUBECONFIG deploy_app
