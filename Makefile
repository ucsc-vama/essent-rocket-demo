riscv_dir = $(abspath ./riscv-local)
generated_dir = $(abspath rocket-chip/emulator/generated-src)
fir_filename = freechips.rocketchip.system.DefaultConfig.fir

essent/README.md:
	git submodule update --init essent

firrtl-sig/README.md:
	git submodule update --init firrtl-sig

rocket-chip/chisel3/README.md:
	git submodule update --init --recursive rocket-chip

riscv-local/lib/libfesvr.so:
	git submodule update --init riscv-fesvr
	mkdir -p $(riscv_dir)
	cd riscv-fesvr; mkdir build; cd build; ../configure --prefix=$(riscv_dir) --target=riscv64-unknown-elf; make install 

$(generated_dir)/$(fir_filename): rocket-chip/chisel3/README.md
	cd rocket-chip/emulator; RISCV=$(riscv_dir) make $(generated_dir)/$(fir_filename)

$(fir_filename): $(generated_dir)/$(fir_filename)
	cp $(generated_dir)/$(fir_filename) .

TestHarness.h: $(fir_filename) essent/README.md
	cd ./essent; sbt 'run $(abspath $(fir_filename))'

CXXFLAGS = -O3 -std=c++11
CLANG_FLAGS = -fno-slp-vectorize -fbracket-depth=1024

UNAME_OS := $(shell uname -s)
ifeq ($(UNAME_OS),Darwin)
	CXXFLAGS += $(CLANG_FLAGS)
endif

INCLUDES = -I../csrc -I$(riscv_dir)/include -I./firrtl-sig
LIBS = -L$(riscv_dir)/lib -Wl,-rpath,$(riscv_dir)/lib -lfesvr -lpthread

emulator: emulator.cc TestHarness.h riscv-local/lib/libfesvr.so
	$(CXX) $(CXXFLAGS) $(INCLUDES) emulator.cc -o emulator $(LIBS)

.PHONY: test

test: emulator
	./emulator +cycle-count ./dhrystone.riscv
