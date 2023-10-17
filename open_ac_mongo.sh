#!/bin/bash
#
# This script opens mongodb compass app on MacOS.
# Point your terminal to the kubeconfig that contains your AC instance.
#
# Required:
# - jq
#
# Usage:
#   ./open_ac_mongo.sh <namespace_of_AC>

ac_ns="${1:-pcloud}"
echo $ac_ns

echo "closing kubectl port-forwards"
pkill kubectl

echo "forwarding mongodb service"
kubectl -n ${ac_ns} port-forward polaris-mongodb-0 11921:11921 > /dev/null 2>&1 &

mongo_secret=$(kubectl get -n ${ac_ns} secrets/polaris-mongodb -o json | jq -r '.data."mongodb-root-password"' | base64 --decode)
echo $mongo_secret

mongo_url="mongodb://root:${mongo_secret}@127.0.0.1:11921/?directConnection=true"

open /Applications/MongoDB\ Compass.app $mongo_url


