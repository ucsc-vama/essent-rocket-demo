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
