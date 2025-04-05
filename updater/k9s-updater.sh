#!/bin/bash

K9S_VERSION='v0.40.10'
wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_linux_amd64.deb
sudo dpkg -i k9s_linux_amd64.deb

rm -f k9s_linux_amd64.deb
