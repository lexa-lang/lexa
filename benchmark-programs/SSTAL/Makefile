bench: test build
	hyperfine --warmup 3 --export-csv results.csv \
		'countdown/main 200000000' \
		'countdown2/main 50000' \
		'product_early/main 100000' \
		'tree_explore/main 16' \
		'scheduler/main 50000'

test: build
	echo "Running programs..."
	cd countdown ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd countdown2 ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd product_early ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd tree_explore ; ./main 5 > actual ; echo 946 > expected ; diff expected actual
	cd scheduler ; ./main 1000 > actual ; echo 2000 > expected ; diff expected actual

build:
	echo "Building programs..."
	cd countdown ; clang -O3 -I ../include main.c -o main
	cd countdown2 ; clang -O3 -I ../include main.c -o main
	cd product_early ; clang -O3 -I ../include main.c -o main
	cd tree_explore ; clang -O3 -I ../include main.c -o main
	cd scheduler ; clang -O3 -I ../include main.c -o main

clean:
	-rm */main
	-rm */expected
	-rm */actual
	-rm results.csv
