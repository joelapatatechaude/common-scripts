#!/bin/bash

function private_repo_creds {
    cat <<EOF | KUBECONFIG=~/.aws/gitops-kubeconfig oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: https://github.com/joelapatatechaude
EOF
}

function private_repo {
    REPO_URL=$(git remote get-url origin)
    REPO_NAME=$(echo $REPO_URL | awk -F '/' '{print $NF}')
    cat <<EOF | KUBECONFIG=~/.aws/gitops-kubeconfig oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-$REPO_NAME
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: $REPO_URL
  password: $GITHUB_PASSWORD
  username: $GITHUB_USERNAME
EOF
}

function gitwebhook {
    REPO_URL=$(git remote get-url origin)
    REPO_NAME=$(echo $REPO_URL | awk -F '/' '{print $NF}')
    echo $REPO_URL
    echo $REPO_NAME
    echo $GITHUB_WEBHOOK_PAC
    echo "return early"
    return
cat <<EOF | KUBECONFIG=~/.aws/gitops-kubeconfig oc apply -f -
apiVersion: redhatcop.redhat.io/v1alpha1
kind: GitWebhook
metadata:
  name: gitwebhook-github-$REPO_NAME
spec:
  gitHub:
    gitServerCredentials:
      name: $GITHUB_WEBHOOK_PAC
  repositoryOwner: joelapatatechaude
  ownerType: user
  repositoryName: $REPO_NAME
  webhookURL: $WEBHOOK_URL
  insecureSSL: false
  webhookSecret:
    name: webhook-secret-$REPO_NAME
  events:
    - push
  contentType: json
  active: true
EOF
}

function create_argo_cluster {
    LIST=$(argocd cluster list --config ~/.aws/argo-config -o json | jq .[].name -r)
    echo "$LIST" | grep "${ARGO_CLUSTER_NAME}"
    if ! [ $? -eq 0 ]
    then
        echo "Adding the cluster $ARGO_CLUSTER_NAME to argocd"
        argocd cluster add $CONTEXT --config ~/.aws/argo-config --name $ARGO_CLUSTER_NAME -y --kubeconfig=$MYDIR/auth/kubeconfig
    fi
}

function create_app_project {
    echo "creating app project"
    cat <<EOF | oc apply -f -
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: $ARGO_CLUSTER_NAME
  namespace: openshift-gitops
spec:
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  destinations:
    - namespace: '*'
      server: '*'
  sourceRepos:
    - '*'
EOF
}

function deploy_app {
    for i in $(ls ${THEDIR:=cluster-go}/argo-app/*.yaml); do
	    oc apply -f $i
    done
}
