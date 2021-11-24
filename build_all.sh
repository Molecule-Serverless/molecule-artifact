#!/bin/bash

## This is a simple script to build each Molecule components one by one
## -- Dong Du

## 1. XPU-shim first
echo -e "\033[44;37m ======[Molecule Builder] Start building XPU-shim \033[0m"
cd xpu-shim/src
make -j8
# create the shared dir used to communicate between XPU-shim and functions
sudo mkdir -p /tmp/fifo_dir

echo -e "\033[42;37m ======[Molecule Builder] Building XPU-shim success \033[0m"


## n. Pull necessary docker images
echo -e "\033[44;37m ======[Molecule Builder] Start pulling AE used docker images \033[0m"
docker pull ddnirvana/molecule-js-env:v3-node14.16.0
echo -e "\033[42;37m ======[Molecule Builder] Pulling images finished \033[0m"
