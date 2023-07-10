#!/bin/sh
source ./env.sh

aa=$(grep "Access the OpenShift web-console here:" ./$MYDIR/.openshift_install.log | tail -1 | awk -F 'web-console here: ' '{print $2}' )
echo "Dashboard: ${aa::-1}"
echo "Username : kubeadmin"
echo "Password : $(cat $MYDIR/auth/kubeadmin-password)"

ARGO_SERVER=$(KUBECONFIG=$MYDIR/auth/kubeconfig oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}')
echo "argo url : https://${ARGO_SERVER}"
echo "argo ep  : $ARGO_SERVER"

ARGO_PASSWORD=$(KUBECONFIG=$MYDIR/auth/kubeconfig oc get secret openshift-gitops-cluster -n openshift-gitops -o json | jq -r '.data."admin.password"' | base64 -d)
echo "argo pwd : $ARGO_PASSWORD"
