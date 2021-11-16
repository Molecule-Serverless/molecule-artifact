## Molecule: ASPLOS'22 Artifact

This artifact lays out the source code and experiment setup for the ACM ASPLOS 2022 conference paper:
*"Serverless Computing on Heterogeneous Computers".*

### 1. Introduction

Molecule is a serverless runtime allowing functions running on heterogeneous devices.
Specifically, we currently support CPU-DPU and CPU-FPGA platforms.

**Hardware requirements:**
- CPU-DPU: You need a computer (with x86 CPU cores) which is equipped with Nvidia Bluefield (both Bluefield-1 and Bluefield-2 are OK).
- CPU-FPGA: You need a computer which is equpped with FPGA card. AWS EC2 F1 instance is perfectly to evalaute this secenario.

To ease AE reviewers quickly build, run, and evaluate Molecule, we have prepared:
- a simulation mode that can using two XPU-Shim in a single CPU to simulate CPU-DPU settings;
- an F1 instance that can be accessed to run cases for CPU-DPU.

**Software requirements:**

1. Git: Molecule uses git for version control
2. Docker: Molecule uses docker to create the build environment
3. Linux: All the testing scripts are developed for Linux (e.g., ubuntu-20.04 we used), which may be incompatible with mac or windows.

All the software requirements are well-prepared in the provided F1 testbed.

### 2. Getting started (artifact available)

Molecule is now an open-sourced our project, see in the git repo:

- https://github.com/Molecule-Serverless/Molecule-Artifact.git

To get the source code of Molecule:

	git clone https://github.com/Molecule-Serverless/Molecule-Artifact.git

Update all submodules:

	git submodule update --init --recursive


Now you have everything needed to run Molecule's tests and reproduce the results.

### 3. Run an example (Functionality)

This section explains demos to run hello-world like functions using Molecule to show the functionality.

#### 3.1 CPU/DPU hello-world function

We use the *frontend* function in Alexa as a case.

1. Switch the Node.js function runtime to single-mode

	# change branch
	cd molecule-js-env && git checkout single-func
	# update submodules
	git submodule update --init --recursive && cd ..

2. Install docker image

For x86 environment, download the ddnirvana/molecule-js-env:v3-node14.16.0 image.

	docker pull ddnirvana/molecule-js-env:v3-node14.16.0

For arm environment (e.g., on DPU), download the ddnirvana/molecule-js-env:v3-node14.16.0-arm.

	docker pull ddnirvana/molecule-js-env:v3-node14.16.0-arm

**Explanation:**

The docker image contains node.js 14.16.0 and some necessary packages.
The Dockerfile and build scripts for the docker image is also open-sourced (TODO), which can be built by developers.

3. Run *frontend* tests

Commands:

	# in molecule-bench dir, enter the docker env
	./docker_run.sh

	# in the /env dir, if the node_modules is empty, execute the following instructiosn
	# it happens for 1st installation
	npm install

	# in /env in the docker environment
	./test_single_func_exec.sh

The script will execute test cases and write data/log to a directory named results/.

The script will run all alexa functions, to run individual, please read the script and comment some cases.


#### 3.2 FPGA hello-world function


#### 3.3 Function-chain between CPU and DPU


### 4. Main results of the paper (Reproducability)

