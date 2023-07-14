#!/bin/sh

function get_cluster_info {
    if [ $CLUSTER_NAME == "crc" ];
    then
	aa=https://console-openshift-console.apps-crc.testing/
    else
	aa=$(grep "Access the OpenShift web-console here:" ./$MYDIR/.openshift_install.log | tail -1 | awk -F 'web-console here: ' '{print $2}' )
    fi
    echo "Dashboard: ${aa::-1}"
    echo "Username : kubeadmin"
    echo "Password : $(cat $MYDIR/auth/kubeadmin-password)"
}
