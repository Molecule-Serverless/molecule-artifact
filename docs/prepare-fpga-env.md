## Preparing FPGA environment for Molecule

Assuming you are using a new F1 instances using CentOS AMI.

1. Basic dependeicies

	sudo yum install vim build-essentials
	sudo yum --enablerepo='*' --disablerepo='media-*' --disablerepo=c7-media  install -y make automake autoconf gettext libtool gcc libcap-devel systemd-devel yajl-devel libseccomp-devel python36 libtool git glibc-static

2. Docker

	sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum install docker-ce docker-ce-cli containerd.io
	sudo systemctl start docker
	sudo docker run hello-world
	sudo groupadd docker
	sudo usermod -aG docker $USER

3. Golang

Following the instructions at https://go.dev/doc/install to install the latest Golang.

You can check the go is properly installed by:

	go version
