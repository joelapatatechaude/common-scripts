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
    REPO_NAME_FULL=$(echo $REPO_URL | awk -F '/' '{print $NF}')
    REPO_NAME=$(basename -s .git $REPO_NAME_FULL)
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

function github_pat_secret {
    #REPO_URL=$(git remote get-url origin)
    #REPO_NAME_FULL=$(echo $REPO_URL | awk -F '/' '{print $NF}')
    #REPO_NAME=$(basename -s .git $REPO_NAME_FULL)
    TOKEN=$(echo $GITHUB_WEBHOOK_PAC | base64 -w 0)
    cat <<EOF | KUBECONFIG=~/.aws/gitops-kubeconfig oc apply -f -
kind: Secret
apiVersion: v1
metadata:
  namespace: openshift-gitops
  name: github-pat
stringData:
  token: ${TOKEN}
EOF
}

function gitwebhook_secret {
    WEBHOOK_SECRET=$(echo $GITHUB_WEBHOOK_SECRET | base64 -w 0)
    cat <<EOF | KUBECONFIG=~/.aws/gitops-kubeconfig oc apply -f -
kind: Secret
apiVersion: v1
metadata:
  namespace: openshift-gitops
  name: webhook-secret
stringData:
  secret: ${WEBHOOK_SECRET}
EOF
}

function gitwebhook {
    REPO_URL=$(git remote get-url origin)
    REPO_NAME_FULL=$(echo $REPO_URL | awk -F '/' '{print $NF}')
    REPO_NAME=$(basename -s .git $REPO_NAME_FULL)
    ARGO_SERVER=$(KUBECONFIG=~/.aws/gitops-kubeconfig oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
    echo $REPO_URL
    echo $REPO_NAME
    echo $GITHUB_WEBHOOK_PAC

cat <<EOF | KUBECONFIG=~/.aws/gitops-kubeconfig oc apply -f -
apiVersion: redhatcop.redhat.io/v1alpha1
kind: GitWebhook
metadata:
  name: gitwebhook-github
  namespace: openshift-gitops
spec:
  gitHub:
    gitServerCredentials:
      name: webhook-secret
  repositoryOwner: joelapatatechaude
  ownerType: user
  repositoryName: $REPO_NAME
  webhookURL: https://$ARGO_SERVER/api/webhook
  insecureSSL: false
  webhookSecret:
    name: github-pat
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
