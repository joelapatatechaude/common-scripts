#!/bin/bash

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
    for i in $(ls cluster-go/argo-app/*.yaml); do
	    oc apply -f $i
    done
}
