uGMTfirmware
============

If you just want to build and use the firmware as-is please see the README for information on how to check out and build it from SVN CACTUS.

## Instructions for setting up the build environment
This has been tested on SLC6, but no guarantees given for anything.

### Check out Github project

```
git clone https://github.com/dinyar/uGMTfirmware.git
```

### Run project setup script
From the root of the uGMTfirmware project:
```
cd uGMT_algos/scripts
bash makeProject.sh [tag, e.g. mp7fw_v2_2_0] ['unstable'/'stable'] [username for svn] [absolute path to checkout mp7fw in]
```

### Generating the Vivado project
Visit the project folder, source the Xilinx environment (if you haven't already) and execute `make project` followed by `make bitfile`:

  ```
  cd [mp7framework_directory]/ugmt
  [source Xilinx environment]
  make project
  bash runAll.sh
  ```
*Note:* Calling `make bitfile` is only necessary the first time after a new checkout in order to generate some required cores. After this follow the instructions in the following section to (re-)build the firmware.

## Instructions for building the firmware

*Note:* If you have the uHAL software installed you can run the following to ensure that the IPbus decoder logic is up-to-date:
```
make addrtab
cd addrtab
../cactus/trunk/cactusupgrades/scripts/firmware/dep_tree.py -p b ../cactus/trunk/cactusupgrades projects/ugmt > mkDecode.sh
chmod u+x mkDecode.sh
./mkDecode.sh
```

The Makefile then provides the facilities to build the project from the command line:

```
cd [mp7framework_directory]/ugmt
bash runAll.sh
```

The bitfile can then be found in the subfolder `pkg`.

## Instructions for running the testbenches

The complete test suite can be run by using the `setupAndRunAllTestPatterns.py` script in `uGMT_algos/firmware/testbench` which runs all available testbenches on all available test patterns. 

A more fine-grained possibiliy is to use `setupAndRunAll.sh`. This script takes as its argument the test pattern type to be used. Currently there are four such test pattern types available:
- `ttbar_small_sample` -- a sample of events from a ttbar generator
- `many_events` -- the uGMT's muons inputs are saturated with muons (i.e. full 108 muons per bx)
- `fwd_iso_scan` -- only forward muons and energy deposits with uniform energy for a given bunch crossing
- `iso_test` -- muons with uniform pT; energy deposits with uniform energy for a given bunch crossing

Individual testbenches can be setup and run with the following commands entered in the root testbench directory (i.e. `uGMT_algos/firmware/testbench`):

```
bash setupSim.sh [directoryOfTestbench, e.g. serializer]
cd [directoryOfTestbench, e.g. serializer]
runSim.sh
```

*Note:* Make sure the Modelsim executables (i.e. `vsim`, etc.) are in your path and usable to run the tests.

