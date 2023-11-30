#!/bin/sh

# need to learn about envsubs
source ./env-local.sh
source <(curl -s https://raw.githubusercontent.com/joelapatatechaude/common-scripts/main/OCP-Demo/1.functions-create-ocp-clusters.sh)

KUBECONFIG=$MYDIR/auth/kubeconfig trust
echo "done updating ca, you might need to restart your browser"
