# Compile flags used to build emulator
CXXFLAGS = -O3 -std=c++11
CLANG_FLAGS = -fno-slp-vectorize -fbracket-depth=1024

UNAME_OS := $(shell uname -s)
ifeq ($(UNAME_OS),Darwin)
	CXXFLAGS += $(CLANG_FLAGS)
endif

INCLUDES = -I../csrc -I$(riscv_dir)/include -I./firrtl-sig
LIBS = -L$(riscv_dir)/lib -Wl,-rpath,$(riscv_dir)/lib -lfesvr -lpthread


# Default target, the emulator for Rocket Chip
emulator: emulator.cc TestHarness.h riscv-local/lib/libfesvr.so
	$(CXX) $(CXXFLAGS) $(INCLUDES) emulator.cc -o emulator $(LIBS)


# Build riscv-fesvr (needed to interface with Rocket Chip)
riscv_dir = $(abspath ./riscv-local)

riscv-local/lib/libfesvr.so:
	git submodule update --init riscv-fesvr
	mkdir -p $(riscv_dir)
	cd riscv-fesvr; mkdir build; cd build; ../configure --prefix=$(riscv_dir) --target=riscv64-unknown-elf; make install 


# Run Rocket Chip to get .fir (FIRRTL) file of design
generated_dir = $(abspath rocket-chip/emulator/generated-src)
fir_filename = freechips.rocketchip.system.DefaultConfig.fir

rocket-chip/chisel3/README.md:
	git submodule update --init --recursive rocket-chip

$(generated_dir)/$(fir_filename): rocket-chip/chisel3/README.md
	cd rocket-chip/emulator; RISCV=$(riscv_dir) make $(generated_dir)/$(fir_filename)

$(fir_filename): $(generated_dir)/$(fir_filename)
	cp $(generated_dir)/$(fir_filename) .


# Run ESSENT to get C++ of Rocket Chip
essent/README.md:
	git submodule update --init essent

firrtl-sig/README.md:
	git submodule update --init firrtl-sig

TestHarness.h: $(fir_filename) essent/README.md firrtl-sig/README.md
	cd ./essent; sbt 'run $(abspath $(fir_filename))'


# Run the emulator with dhrystone (binary included in repo)
.PHONY: test

test: emulator
	./emulator +cycle-count ./dhrystone.riscv
