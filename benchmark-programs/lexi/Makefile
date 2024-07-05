
# 'product_early/main 100000', 'handler_sieve/main 60000', 'interruptible_iterator/main 3000'
bench: build
	hyperfine --warmup 3 --export-csv results.csv \
		'countdown/main 200000000' \
		'fibonacci_recursive/main 42' \
		'iterator/main 40000000' \
		'nqueens/main 12' \
		'tree_explore/main 16' \
		'triples/main 300' \
		'resume_nontail/main 10000' \
		'parsing_dollars/main 20000' \
		'handler_sieve/main 60000' \
		'scheduler/main 3000' \
		"interruptible_iterator/main 3000"

# 'product_early/main 100000', 'handler_sieve/main 60000', 'interruptible_iterator/main 3000'
bench-c-only: build-c-only
	hyperfine --warmup 3 --export-csv results.csv \
		'countdown/main 200000000' \
		'fibonacci_recursive/main 42' \
		'iterator/main 40000000' \
		'nqueens/main 12' \
		'tree_explore/main 16' \
		'triples/main 300' \
		'resume_nontail/main 10000' \
		'parsing_dollars/main 20000' \
		'handler_sieve/main 60000' \
		'scheduler/main 3000'  \
		"interruptible_iterator/main 3000"

test: build
	echo "Running programs..."
	cd countdown ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd fibonacci_recursive ; ./main 5 > actual ; echo 5 > expected ; diff expected actual
	cd product_early ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd iterator ; ./main 5 > actual ; echo 15 > expected ; diff expected actual
	cd nqueens ; ./main 5 > actual ; echo 10 > expected ; diff expected actual
	cd tree_explore ; ./main 5 > actual ; echo 946 > expected ; diff expected actual
	cd triples ; ./main 10 > actual ; echo 779312 > expected ; diff expected actual
	cd resume_nontail ; ./main 5 > actual ; echo 37 > expected ; diff expected actual
	cd parsing_dollars ; ./main 10 > actual ; echo 55 > expected ; diff expected actual
	cd handler_sieve ; ./main 10 > actual ; echo 17 > expected ; diff expected actual
	cd scheduler ; ./main 10 > actual ; echo 10000 > expected ; diff expected actual
	cd interruptible_iterator ; ./main 10 > actual ; echo 90000 > expected ; diff expected actual

test-c-only: build-c-only
	echo "Running programs..."
	cd countdown ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd fibonacci_recursive ; ./main 5 > actual ; echo 5 > expected ; diff expected actual
	cd product_early ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd iterator ; ./main 5 > actual ; echo 15 > expected ; diff expected actual
	cd nqueens ; ./main 5 > actual ; echo 10 > expected ; diff expected actual
	cd tree_explore ; ./main 5 > actual ; echo 946 > expected ; diff expected actual
	cd triples ; ./main 10 > actual ; echo 779312 > expected ; diff expected actual
	cd resume_nontail ; ./main 5 > actual ; echo 37 > expected ; diff expected actual
	cd parsing_dollars ; ./main 10 > actual ; echo 55 > expected ; diff expected actual
	cd handler_sieve ; ./main 10 > actual ; echo 17 > expected ; diff expected actual
	cd scheduler ; ./main 10 > actual ; echo 10000 > expected ; diff expected actual
	cd interruptible_iterator ; ./main 10 > actual ; echo 110000 > expected ; diff expected actual

build-c-only:
	echo "Building programs..."
	cd countdown ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd fibonacci_recursive ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd product_early ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd iterator ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd nqueens ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd tree_explore ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd triples ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd resume_nontail ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd parsing_dollars ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd handler_sieve ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd scheduler ; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd interruptible_iterator ; clang -O3 -g -I ../../../stacktrek main.c -o main

build:
	echo "Building programs..."
	cd countdown ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd fibonacci_recursive ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd product_early ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd iterator ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd nqueens ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd tree_explore ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd triples ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd resume_nontail ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd parsing_dollars ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd handler_sieve ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd scheduler ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	cd interruptible_iterator ; dune exec -- sstal main.ir -o main.c; clang-format -i main.c; clang -O3 -g -I ../../../stacktrek main.c -o main
	


clean:
	-rm -r */out/
	-rm */main
	-rm results.csv
	-rm */expected
	-rm */actual
