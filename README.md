uGMTfirmware
============

Firmware for the CMS uGMT.

This repository contains the algorithm part of the CMS uGMT firmware. It has been written for the Imperial MP7, a Virtex-7 based AMC module.

This most probably isn't of use for anyone outside the CMS Level-1 Trigger.

## Instructions for setting up the build environment
This has been tested on SLC6, but no guarantees given for anything.

### Obtaining required sources
Instructions for obtaining the MP7 framework firmware can be found at https://twiki.cern.ch/twiki/bin/viewauth/CMS/MP7FirmwareNews. These should be followed until step 6. 

Following this check out the uGMT algorithms to a directory of your choice. The `uGMT_algos` should either be linked or copied to `cactusupgrades/components/`:

```
cd [mp7framework_directory]/cactusupgrades/components
ln -s [...]/uGMTfirmware/uGMT_algos uGMT_algos
```

### Auto-generating the ISE project
To automatically generate an ISE project file the following steps then need to be followed:

1. Add `include -c components/uGMT_algos uGMT_algo.dep` and `addrtab -t mp7_payload.xml` to `cactusupgrades/components/mp7_null_algo/firmware/cfg/mp7_null_algo.dep`
2. Copy `mp7_payload.xml` from `uGMTfirmware` to `cactusupgrades/components/mp7_null_algo/addr_table`
3. Replace the existing payload entry in `cactusupgrades/components/mp7_infra/addr_table/mp7_infra.xml` with `<node id="payload" module="file://mp7_payload.xml" address="0x1000000" fwinfo="endpoint"/>`
4. Go back to the project folder `mp7_690es`, source the ISE environment and run `make project`:
```
cd [mp7framework_directory]/mp7_690es
source /opt/Xilinx/14.6/ISE_DS/settings64.sh
make project
```
5. Add the `ugmt_serdes.vhd` block definition to the top block. You can find it in `cactusupgrades/boards/mp7/base_fw/mp7_690es/firmware/hdl/mp7_690es.vhd`
6. Finally visit the project folder and execute `make project`:
```
cd 
make project
```

## Instructions for building the firmware
An included script can be used to generate a bitfile in one step. The follwoign set up is necessary for this to work:

1. Copy `runAllImplementationSteps.sh` from `uGMTfirmware` to `[mp7framework_directory]/mp7_690es` and make executable:
```
cd [mp7framework_directory]/mp7_690es
cp uGMTfirmware/runAllImplementationSteps.sh .
chmod u+x runAllImplementationSteps.sh
```
2. Copy both smartxplorer config files to a directory of your choosing:
```
mkdir -p ~/workspace/smartxplorer/config/
cp uGMTfirmware/smartxplorer_* ~/workspace/smartxplorer/config/.
```
3. Create a directory to store the results of all smartxplorer runs (N.B.: This should be a local directory as the results can become large (O(10 GB)):
```
mkdir /tmp/smartxplorer_resuls/
```
4. Modify the file with you favourite editor and set the path to the config files and the working directory according to the above. Finally uncomment the line outputting the warning.
5. Run the script:
```
./runAllImplementationSteps.sh
```

To create (or modify the existing) custom strategies consult the Xilinx documentation (or contact me).
