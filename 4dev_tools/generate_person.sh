#!/bin/bash

acao=gerar_pessoa
pontuacao=S
idade=35
estado=PR
quantidade=5
cidade=6015

query_string="acao=$acao"
query_string="$query_string&sexo=I"
query_string="$query_string&pontuacao=$pontuacao"
query_string="$query_string&idade=$idade"
query_string="$query_string&cep_estado=$estado"
query_string="$query_string&txt_qtde=$quantidade"
query_string="$query_string&cep_cidade=$cidade"

curl -sd "$query_string" https://www.4devs.com.br/ferramentas_online.php | jq
