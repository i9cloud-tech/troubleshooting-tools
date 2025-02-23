#!/bin/bash

acao=gerar_pessoa
pontuacao=S
idade=35
estado=PR
quantidade=5
cidade=6015

curl -sd "acao=$acao&sexo=I&pontuacao=$pontuacao&idade=$idade&cep_estado=$estado&txt_qtde=$quantidade&cep_cidade=$cidade" \
https://www.4devs.com.br/ferramentas_online.php | jq