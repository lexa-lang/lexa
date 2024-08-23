bench: build
	hyperfine --warmup 3 --export-csv results.csv \
		'countdown/main 200000000' \
		'fibonacci_recursive/main 42' \
		'product_early/main 100000' \
		'iterator/main 40000000' \
		'nqueens/main 12' \
		'tree_explore/main 16' \
		'triples/main 300' \
		'resume_nontail/main 10000' \
		'parsing_dollars/main 20000' \
		'handler_sieve/main 60000' \
		'scheduler/main 3000'

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
	

build:
	echo "Building programs..."
	cd countdown ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd fibonacci_recursive ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd product_early ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd iterator ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd nqueens ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd tree_explore ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd triples ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd resume_nontail ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd parsing_dollars ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd handler_sieve ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	cd scheduler ; opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml
	

clean:
	-rm */main.cmi
	-rm */main.cmx
	-rm */main.o
	-rm */main
	-rm */expected
	-rm */actual
	-rm results.csv
