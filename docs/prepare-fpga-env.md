## Preparing FPGA environment for Molecule

1. Docker

	sudo yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
	sudo yum install docker-ce docker-ce-cli containerd.io
	sudo systemctl start docker
	sudo docker run hello-world
	sudo groupadd docker
	sudo usermod -aG docker $USER
