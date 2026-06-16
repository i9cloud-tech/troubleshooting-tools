#!/bin/bash

main() {
  nodes=`kubectl get nodes \
    -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.conditions[*].status}{"\n"}{end}' \
    | grep "Unknow" \
    | awk '$1!="True" {print $1}'`

  for node in $nodes; do
      echo "Processando nó obsoleto: $node"
      aws_intance_ids=$(get_aws_instance_ids $node)
      #cordon_node $node
      #drain_node $node
      remove_node_from_cluster $node
      remove_aws_instance $aws_intance_ids
  done
}

get_aws_instance_ids() {
  local node=$1
  kubectl get node $node -o jsonpath='{.spec.providerID}' | awk -F'/' '{print $NF}'
}

cordon_node() {
  local node=$1
  kubectl cordon $node
}

drain_node() {
  local node=$1
  kubectl drain $node --ignore-daemonsets --delete-emptydir-data --force --grace-period=30
}

remove_node_from_cluster() {
  local node=$1
  kubectl delete node $node
}

remove_aws_instance() {
  local instance_id=$1
  aws ec2 terminate-instances --instance-ids ${aws_intance_ids}
  echo "Instância AWS EC2 ${aws_intance_ids} associada ao nó $node removida."
}

main
