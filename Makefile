C_DIR = test/c_progs
IR_DIR = test/ir_progs
OUT_DIR = test/out
INCLUDE_DIR = stacktrek

ir-compile:
	@echo "Compiling IR programs..."
		for file in $(IR_DIR)/*.ir; do \
		filename=$$(basename $$file); \
		outputfile=$(C_DIR)/$${filename%.*}.c; \
		dune exec -- sstal "$$file" -o "$$outputfile"; \
	done
	@echo "IR programs compiled successfully."

c-compile:
	@echo "Compiling C programs..."
	for file in $(C_DIR)/*.c; do \
		filename=$$(basename $$file); \
		outputfile=$(OUT_DIR)/$${filename%.*}.out; \
		clang -O3 -I $(INCLUDE_DIR) "$$file" -o "$$outputfile"; \
	done
	@echo "C programs compiled successfully."

c-test: ir-compile c-compile
	@echo "Running programs..."
	for file in $(OUT_DIR)/*.out; do \
		echo "Running: $$file"; \
		$$file 5; \
	done
	@echo "Tests completed."