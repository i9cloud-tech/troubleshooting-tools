#!/bin/bash
set -x

kubectl create deployment $1 --dry-run=client --image public.ecr.aws/q0a7a5m8/amicci-aws-eks:v1.2 -o yaml | tee $1.deployment.yaml
