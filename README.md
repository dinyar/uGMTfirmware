uGMTfirmware
============

Firmware for the CMS uGMT.

This repository contains the algorithm part of the CMS uGMT firmware. It has been written for the Imperial MP7, a Virtex-7 based AMC module.

This most probably isn't of use for anyone outside the CMS Level-1 Trigger.

## Instructions for setting up the build environment
This has been tested on SLC6, but no guarantees given for anything.

### Check out Github project

```
git clone https://github.com/dinyar/uGMTfirmware.git
```

If you're not planning to introduce changes and contribute back to the project. Otherwise fork this repository and then work on your copy.

### Run project setup script
From the root of the uGMTfirmware project:
```
cd scripts
bash makeProject.sh
```
### Edit project files
1. Replace the existing payload entry in `cactusupgrades/components/mp7_infra/addr_table/mp7xe_infra.xml` with `<node id="payload" module="file://ugmt_serdes.xml" address="0x80000000" fwinfo="endpoint"/>`
2. Replace the payload definition with the `ugmt_serdes.vhd` block definition

  ```
  algo : entity work.ugmt_serdes
  generic map (
    NCHAN     => 72,
    VALID_BIT => '1'
    )
  port map (
    clk_ipb => clk_ipb,
    rst     => rst_ipb,
    ipb_in  => ipb_in_payload,
    ipb_out => ipb_out_payload,
    clk240  => clk_p,
    clk40   => clk40,
    d       => payload_d,
    q       => payload_q
    );
  ```
  in the top block. You can find it in `cactusupgrades/boards/mp7/base_fw/mp7xe_690/firmware/hdl/mp7xe_690.vhd`
  
### Generating the Vivado project
Visit the project folder, source the Xilinx environment (if you haven't already) and execute `make project` followed by `make bitfile`:

  ```
  cd [mp7framework_directory]/mp7xe_690
  [source Xilinx environment]
  make project
  make bitfile
  ```
*Note:* Calling `make bitfile` is only necessary the first time after a new checkout in order to generate some required cores. After this follow the instructions in the following section to (re-)build the firmware.

## Instructions for building the firmware

*Note:* If you have the uHAL software installed you can run the following to ensure that the IPbus decoder logic is up-to-date:
```
make addrtab
cd addrtab
../cactus/trunk/cactusupgrades/scripts/firmware/dep_tree.py -p b ../cactus/trunk/cactusupgrades projects/examples/mp7xe_690 > mkDecode.sh
chmod u+x mkDecode.sh
./mkDecode.sh
```

The provided Makefile then provides the facilities to build the project from the command line:

```
cd [mp7framework_directory]/mp7xe_690
bash runAll.sh
```

The bitfile can then be found in the subfolder `pkg`.

## Instructions for running the testbenches

The complete test suite can be run by using the `setupAndRunAll.sh` script in `uGMT_algos/firmware/testbench`. This script takes as its argument the test pattern type to be used. Currently there are four such test pattern types available:
- `ttbar_small_sample` -- a sample of events from a ttbar generator
- `many_events` -- the uGMT's muons inputs are saturated with muons (i.e. full 108 muons per bx)
- `fwd_iso_scan` -- only forward muons and energy deposits with uniform energy for a given bunch crossing
- `iso_test` -- muons with uniform pT; energy deposits with uniform energy for a given bunch crossing

Individual testbenches can be setup and run with the following commands entered in the root testbench directory (i.e. `uGMT_algos/firmware/testbench`):

```
bash setupSim.sh [directoryOfTestbench, e.g. deserializer]
cd [directoryOfTestbench, e.g. deserializer]
runSim.sh
```

*Note:* Make sure the Modelsim executables (i.e. `vsim`, etc.) are in your path and usable to run the tests.
