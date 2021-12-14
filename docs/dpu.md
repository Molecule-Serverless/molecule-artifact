## Running Tests on DPU

This docs present instructions to run tests on DPUs.

### Hello-world

Build the system:

	./build_all_arm.sh

Then, run the tests

	cd molecule-benchmakrs
	./single-func/arm_docker_build.sh
	./single-func/arm_docker_run.sh

You shall see the results
