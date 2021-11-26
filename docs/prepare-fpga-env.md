## Preparing FPGA environment for Molecule

1. Docker

	sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum install docker-ce docker-ce-cli containerd.io
	sudo systemctl start docker
	sudo docker run hello-world
	sudo groupadd docker
	sudo usermod -aG docker $USER

2. Golang

Following the instructions at https://go.dev/doc/install to install the latest Golang.

You can check the go is properly installed by:

	go version
