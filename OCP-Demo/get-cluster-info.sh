#!/bin/sh
source ./env.sh

aa=$(grep "Access the OpenShift web-console here:" ./$MYDIR/.openshift_install.log | tail -1 | awk -F 'web-console here: ' '{print $2}' )
echo "Dashboard: ${aa::-1}"
echo "Username : kubeadmin"
echo "Password : $(cat $MYDIR/auth/kubeadmin-password)"
