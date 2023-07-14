#!/bin/sh
source ./env.sh

function delete {
    date
    cd $MYDIR
    openshift-install destroy cluster
}

function delete_argo_cluster {
    # doesnt' work, permission issue
    LIST=$(argocd cluster list --config $ARGO_CONFIG -o json | jq .[].name -r)
    echo "$LIST" | grep "${ARGO_CLUSTER_NAME}"
    if [ $? -eq 0 ]
    then
        echo "Removing the cluster $ARGO_CLUSTER_NAME to argocd"
        argocd cluster rm --config $ARGO_CONFIG $ARGO_CLUSTER_NAME
    fi
}

MYDIR=$MYDIR delete
#ARGO_CLUSTER_NAME=$ARGO_CLUSTER_NAME delete_argo_cluster
