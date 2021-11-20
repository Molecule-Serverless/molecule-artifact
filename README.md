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

Commands:

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
The Dockerfile to build the docker image is also open-sourced (molecule-js-env/Dockerfile).

3. Run *frontend* tests

Commands:

	# in molecule-benchmarks dir, enter the docker env
	./docker_run.sh

	# in the /env dir, if the node_modules is empty, execute the following instructiosn
	# it happens for 1st installation
	npm install

	# in /env in the docker environment
	./test_single_func_exec.sh

The script will execute test cases and write data/log to a directory named results/.

The script will run all alexa functions, to run individual, please read the script and comment some cases.


#### 3.2 FPGA hello-world function

To run a vector-multiple FPGA function:

1. Build the runf vector-sandbox runtime

Commands:

	cd vsandbox-runtime
	./autogen.sh
	./configure
	make -j8

If you are using your own environment, please follow the README.md in vsandbox-runtime to install necessary dependencies.

2. Run the demo

In the vsandbox-runtime dir:

	mkdir vsandbox-test && cd vsandbox-test
	../vsandbox-runtime spec
	../vsandbox-runtime run demo-sandbox

You shall see the results like:

<img alt="FPGA function demo" src="./docs/molecule-ae-fpga-demo.png" width="512">


#### 3.3 Function-chain between CPU and DPU


### 4. Main results of the paper (Reproducability)

In this part, we first explain detail steps on how to reproduce the key results
of each techniques (i.e., cfork and IPC-based DAG) in Molecule, which shall
give the reviewer sufficient confidence about the artifact.
Afterthat, we give instructions to run scripts that can generate the results
of benchmarks and applications.

#### 4.1 cFork on single-PU (e.g., CPU or DPU)

This section shows how to reproduce results in Figure-10 (a) and (b).

* Prepare Molecule's runc (which supports cFork)
``` bash
cd runc
git checkout c12a5deed022ada93f499cc90fed54a23f0eb4d9
make static

```

* Prepare forable-python-runtime  environment
``` bash
cd forkable-python-runtime
# change the config of the runc path
cd scripts
vim config
# modify RUNC to your path of the compiled runc

```

* Run tests
``` bash
cd forkable-python-runtime/scripts
./kill_containers.sh # make sure that no old container exists

./base_build.sh # build baseline container's bundle

./template_build.sh # build template container's bundle
./endpoint_build.sh # build endpoint container's bundle

# test baseline works
./run_baseline.sh

# test cfork works
./run_fork.sh

# usage: python3 test_fork.py [test]
# test can be baseline or fork
# if no test is specified, it runs all tests by default
# Caution: if the test is "fork", please make sure that you have run ./run_fork.sh successfully to warm up the environment
python3 test_fork.py
```

You shall see the results like:


<img alt="cfork on single-PU" src="./docs/cfork-singlePU.png" width="512">

#### 4.2 IPC-based DAG on single-PU (e.g., CPU or DPU)

We prepare scripts to run chained serverless functions and generate the
communication latency, as the Figure-12 in the paper.

Commands:

	cd molecule-js-env && git checkout hetero_ipc
	cd src/tests/ipc/stages/
	# This script will run all the four cases (in Figure-12)
	./run_alexa_stage_tests.sh -a

You shall see the results like:


<img alt="IPC-based DAG on single-PU" src="./docs/ipc-dag-singlePU.png" width="512">

This confirms the claims in the paper that IPC-based DAG communication
can achieve significant lower latency (about 100--500us in most cases)
compared with baseline.


#### 4.3 cFork on cross-PU (e.g., CPU-CPU or CPU-DPU)

In this case, we will rely on neighborIPC provided by XPU-shim to fork on an instance.


Build and run XPU-shim:

	cd xpu-shim/src
	make -j8
	# create the shared dir used to communicate between XPU-shim and functions
	sudo mkdir -p /tmp/fifo_dir
	sudo ./moleculeos -i 0

Start Molecule-worker on each PU:

	cd runc && git checkout molecule-cfork
	make static
	sudo ./runc runtime

You will see the runtime is now connected to the XPU-shim.


In another PU (or the same PU if you just simulate two PUs on the same CPU):

	cd forkable-python-runtime/scripts
	./base_build.sh # build baseline container's bundle
	cd ../../
	cd moleculeruntimeclient
	make
	sudo ./molecule_rpc_client run -i 1 -c python-test -b ~/.base/container0
	sudo ./molecule_rpc_client run -i 1 -c app-test -b ~/.base/spin0

Now you can fork the instances on remote PU:

	sudo ./molecule_rpc_client cfork -i 1 -t python-test -p app-test

You shall see the results like:


<img alt="cFork on cross-PU" src="./docs/cfork-crossPU.png" width="512">

This confirms the claims in the paper (Figure-11-a) that the cFork can achieve
about 30ms even in cross-PU settings.

**Note:** we do not apply the kernel optimization (CPUset opt), which is the biggest
costs as shown in the breakdown in the above figure.
We provide the patch in TODO_DIR, and users can feel free to apply and test the patch
if they would.

#### 4.4 IPC-based DAG on cross-PU (e.g., CPU-CPU or CPU-DPU)

The steps are similiar to 4.2 o evaluate DAG performance on cross-PU.
The major change is to prepare a XPU-shim in advance before running benchmarks.

Build and run XPU-shim:

	cd xpu-shim/src
	make -j8
	# create the shared dir used to communicate between XPU-shim and functions
	sudo mkdir -p /tmp/fifo_dir
	sudo ./moleculeos -i 0

Run benchmarks:

	cd molecule-js-env && git checkout hetero_ipc_neighborIPC
	cd src/tests/ipc/stages/
	# This script will run all the four cases (in Figure-12)
	./run_alexa_stage_tests.sh -a

You shall see the results like:

<img alt="IPC-based DAG on cross-PU" src="./docs/ipc-dag-crossPU.png" width="512">

This confirms the claims in the paper that XPU-shim's neighbor IPC
can help functions on different PU to achieve low communication latency
(about 150--600us in most cases).

#### 4.5 FPGA function startup breakdown

This section shows how to reproduce results in Figure-10 (c).

**Note:** We assume the vsandbox is correctly compiled. If it is not, please do it following the instructions above.

Commands:

In the vsandbox-runtime dir:

	mkdir vsandbox-test && cd vsandbox-test
	../vsandbox-runtime spec
	## The following command will run all the tests
	../FPGA_serverless_cli -b

After that, you shall see the results like (including startup latency of four cases):

<img alt="FPGA function startup breakdown" src="./docs/FPGA-startup-breakdown.png" width="512">


Specifically:

* in the first case, the total latency is 15+5.53+2 = 22.52s in the figure, which matches the 1st bar in Figure-10(c);
* in the second case, the total latency is 1.83+1.9=3.73s, which matches the 2nd bar in Figure-10(c);
* in the third case, the total latency is 1.9s, which matches the 3rd bar in Figure-10(c);
* in the fourth case, the total latency is 46ms, which matches the 4th bar in Figure-10(c).

#### 4.6 Benchmarks and Applications


To reproduce FPGA benchmark results (Fig-14 e,f,g):

	cd molecule-benchmarks/fpga-apps
	./run_bench.sh

You shall see the results like:

<img alt="FPGA benchmarks" src="./docs/FPGA-benchmarks.png" width="512">


The above fig shows the results of GZIP latency for FPGA and CPU, which totally match the result of Fig-14 (e).
