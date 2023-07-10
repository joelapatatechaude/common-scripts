#!/bin/sh

source ./env.sh
source <(curl -s https://raw.githubusercontent.com/joelapatatechaude/common-scripts/main/OCP-Demo/functions-get-cluster-info.sh)

get_cluster_info
