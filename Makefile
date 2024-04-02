C_DIR = test/c_progs
IR_DIR = test/ir_progs

compile:
	@echo "Compiling IR..."
		for file in $(IR_DIR)/*.ir; do \
		filename=$$(basename $$file); \
		outputfile=$(C_DIR)/$${filename%.*}.c; \
		dune exec -- sstal "$$file" -o "$$outputfile"; \
	done
	@echo "IR compiled successfully."
