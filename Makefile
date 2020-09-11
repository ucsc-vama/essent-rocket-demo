riscv_dir := $(shell pwd)/riscv-local

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
