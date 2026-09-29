#!/bin/bash

CHARS=$1

password=`openssl rand -base64 ${CHARS:-20}`

echo $password
