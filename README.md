# Demo of Rocket Chip using ESSENT

This repo shows the ease of using [Rocket Chip](https://github.com/chipsalliance/rocket-chip) with [ESSENT](https://github.com/ucsc-vama/essent). To build the simulator (using ESSENT):

    $ make emulator

To run a microbenchmark to see it works:

    $ make test

The demo uses a Makefile to automate the various steps. Since Rocket Chip already uses Verilator, the changes required to are all confined to `emulator.cc`. A quick overview of the flow:
+ Clone the submodules to bring in the needed parts
+ Use the Rocket Chip repo to generate a FIRRTL file for the design. _Note: this is the longest step, as the Rocket Chip repo will download and build its own version of Verilator. The Verilator version of the simulator is handy for comparison._
+ Use ESSENT to produce C++ (TestHarness.h) for the emulator
+ Compile and link the emulator
