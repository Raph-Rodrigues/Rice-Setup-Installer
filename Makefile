.PHONY: run clean

run:
	@mkdir -p build
	@cd build && cmake .. && make clean && make -j$(nproc)
	@ln -sf build/compile_commands.json compile_commands.json
	@cd build && ./installer_rice-setup

clean:
	@rm -rf build compile_commands.json
