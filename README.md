uGMTfirmware
============

Firmware for the CMS uGMT.

This repository contains the algorithm part of the CMS uGMT firmware. It has been written for the Imperial MP7, a Virtex-7 based AMC module.

This most probably isn't of use for anyone outside the CMS Level-1 Trigger.

## Instructions for setting up the build environment
This has been tested on SLC6, but no guarantees given for anything.

*NOTE:* If you're planning to introduce changes and contribute back to the project follow the instructions in CONTRIBUTING.md.

Full instructions on how to check out a CACTUS project and build it can be found at https://twiki.cern.ch/twiki/bin/view/CMS/MP7FirmwareNews. Replace `examples/mp7xe_690` with `ugmt` as project and possibly `trunk` with your preferred tag.

It is then possible to setup and build the uGMT firmware by issuing `make project` followed by `make bitfile` and `make package` as described in the Twiki. After having run `make bitfile` the command `make reset` has to be used before another build can be performed.

## Instructions for running the testbenches

The complete test suite can be run by using the `setupAndRunAllTestPatterns.py` script in `projects/ugmt/firmware/testbench` (if checked out via SVN -- else see CONTRIBUTING.md) which runs all available testbenches on all available test patterns.

A more fine-grained possibiliy is to use `setupAndRunAll.sh`. This script takes as its argument the test pattern type to be used. Currently there are four such test pattern types available:
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

## Versioning

The uGMT is versioned (as of version 2.1.0) with the following scheme:

Mayor version: Changes that require significant interventions at p5. e.g.: online software version changes, link protocol changes, etc.
Minor version: Changes that require modifications to offline software (i.e. the emulator). i.e. algorithm changes
"Very minor" version: Changes and additions to monitoring facilities
Patch level: Bug fixes

This is stored in a 32 bit word in the firmware, thus it makes sense to store each such value in one octet.
