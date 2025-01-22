#!/bin/bash
set -x

kubectl create deployment $1 --dry-run=client --image $2 -o yaml | tee $1.deployment.yaml
