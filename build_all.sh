#!/bin/bash

## This is a simple script to build each Molecule components one by one
## -- Dong Du

## 1. XPU-shim first
echo -e "\033[44;37m ======[Molecule Builder] Start building XPU-shim \033[0m"
pushd xpu-shim/src > /dev/null 2>&1
make -j8
# create the shared dir used to communicate between XPU-shim and functions
sudo rm -rf /tmp/fifo_dir
sudo mkdir -p /tmp/fifo_dir
popd > /dev/null 2>&1
echo -e "\033[42;37m ======[Molecule Builder] Building XPU-shim success \033[0m"

## 2. vsandbox
echo -e "\033[44;37m ======[Molecule Builder] Start building vsandbox \033[0m"
pushd vsandbox-runtime > /dev/null 2>&1
./autogen.sh
### we should disable systemd to build it on CentOS (F1 instances)
./configure --disable-systemd
make -j8
popd > /dev/null 2>&1
echo -e "\033[42;37m ======[Molecule Builder] Building vsandbox success \033[0m"

## 3. cfork runc
echo -e "\033[44;37m ======[Molecule Builder] Start building cfork-runc \033[0m"
pushd runc > /dev/null 2>&1
### we should disable systemd to build it on CentOS (F1 instances)
make
popd > /dev/null 2>&1
echo -e "\033[42;37m ======[Molecule Builder] Building cfork-runc success \033[0m"


## n. Pull necessary docker images
echo -e "\033[44;37m ======[Molecule Builder] Start pulling AE used docker images \033[0m"
docker pull ddnirvana/molecule-js-env:v3-node14.16.0
echo -e "\033[42;37m ======[Molecule Builder] Pulling images finished \033[0m"


echo -e "\033[44;37m ======[Molecule Builder] Pulling large files \033[0m"
pushd molecule-benchmarks/ > /dev/null 2>&1
git lfs pull
popd > /dev/null 2>&1
echo -e "\033[42;37m ======[Molecule Builder] Pulling files finished \033[0m"

