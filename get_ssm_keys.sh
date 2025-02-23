#!/bin/bash
file_name=$1
number_of_keys=$2
ssmkeys=""

main() {
  get_ssm_key_name
  generate_secrets_manager_json
  print_output
  remove_temp_file
}

get_ssm_key_name() {
  ssmkeys=`cat ${file_name} | \
    grep 'secret:' -A ${number_of_keys} | \
    sed '1d' | \
    awk '{print $1 $4}'`
}

generate_secrets_manager_json() {
  i=0
  total=`wc -l <<< "$ssmkeys"`
  echo "{" > secrets_manager.json
  for key in $ssmkeys; do
    i=$((i+1))
    echo "working on $key"
    param_name=`echo "$key" | cut -d ':' -f 2 | tr -d '"'`
    param_value=`aws ssm get-parameter --name $param_name --with-decryption | jq '.Parameter.Value'`
    param_key=`echo $key | cut -d ':' -f 1 | awk '{print "\"" $1 "\""}'`
    if [ $i -eq $total ]; then
      echo "$param_key: $param_value" >> secrets_manager.json
    else
      echo "$param_key: $param_value," >> secrets_manager.json
    fi
  done
  echo "}" >> secrets_manager.json
}

print_output() {
  cat secrets_manager.json | jq
}
remove_temp_file() {
  rm -f secrets_manager.json
}

main
