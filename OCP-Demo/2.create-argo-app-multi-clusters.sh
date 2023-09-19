#!/bin/bash
source ~/.aws/route53
source ./env.sh
source ~/.aws/github
source ~/.aws/github-webhook
source <(curl -s https://raw.githubusercontent.com/joelapatatechaude/common-scripts/main/OCP-Demo/2.functions-create-argo-app.sh)
CONTEXT=admin
PROJECT=default

private_repo_creds
private_repo

manual_webhook


MYDIR=$MYDIR_1 ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME_1 create_argo_cluster
MYDIR=$MYDIR_2 ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME_2 create_argo_cluster
sleep 1

ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME_1 KUBECONFIG=$HUB_KUBECONFIG create_app_project
ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME_2 KUBECONFIG=$HUB_KUBECONFIG create_app_project
sleep 1

KUBECONFIG=$HUB_KUBECONFIG THEDIR=sydney-go deploy_app
KUBECONFIG=$HUB_KUBECONFIG THEDIR=singapore-go deploy_app
