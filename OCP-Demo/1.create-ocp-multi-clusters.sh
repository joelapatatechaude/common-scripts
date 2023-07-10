#!/bin/sh

source ~/.aws/route53
source ~/.aws/pullsecret
source ./env.sh
source <(curl -s https://raw.githubusercontent.com/joelapatatechaude/common-scripts/main/OCP-Demo/1.functions-create-ocp-clusters.sh)

FAIL=0

CLUSTER_NAME=$CLUSTER_NAME_1 REGION=$REGION_1 MYDIR=$MYDIR_1 cluster > >(tee -a $CLUSTER_NAME_1.log) 2> >(tee -a $CLUSTER_NAME_1.log >&2) &
CLUSTER_NAME=$CLUSTER_NAME_2 REGION=$REGION_2 MYDIR=$MYDIR_2 cluster > >(tee -a $CLUSTER_NAME_1.log) 2> >(tee -a $CLUSTER_NAME_1.log >&2) &

for job in `jobs -p`
do
    wait $job || let "FAIL+=1"
done

if [ "$FAIL" == "0" ];
then
    echo "sucessfully created the two(?) clusters"
else
    echo "FAIL! $FAIL"
    echo "check the log files"
fi

KUBECONFIG=$MYDIR_1/auth/kubeconfig trust
KUBECONFIG=$MYDIR_2/auth/kubeconfig trust
