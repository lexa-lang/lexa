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
		'parsing_dollars/main 20000'

test: build
	echo "Running programs..."
	cd countdown ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd fibonacci_recursive ; ./main 5 > actual ; echo 5 > expected ; diff expected actual
	cd product_early ; ./main 5 > actual ; echo 0 > expected ; diff expected actual
	cd iterator ; ./main 5 > actual ; echo 15 > expected ; diff expected actual
	cd nqueens ; ./main 5 > actual ; echo 10 > expected ; diff expected actual
	cd tree_explore ; ./main 5 > actual ; echo 946 > expected ; diff expected actual
	cd triples ; ./main 10 > actual ; echo 779312 > expected ; diff expected actual
	cd parsing_dollars ; ./main 10 > actual ; echo 55 > expected ; diff expected actual
	cd resume_nontail ; ./main 5 > actual ; echo 37 > expected ; diff expected actual

build:
	echo "Building programs..."
	cd countdown ; mlton -default-type int64 -output main main.sml
	cd fibonacci_recursive ; mlton -default-type int64 -output main main.sml
	cd product_early ; mlton -default-type int64 -output main main.sml
	cd iterator ; mlton -default-type int64 -output main main.sml
	cd nqueens ; mlton -default-type int64 -output main main.sml
	cd tree_explore ; mlton -default-type int64 -output main main.sml
	cd triples ; mlton -default-type int64 -output main main.sml
	cd parsing_dollars ; mlton -default-type int64 -output main main.sml
	cd resume_nontail ; mlton -default-type int64 -output main main.sml

clean:
	-rm */main
	-rm */expected
	-rm */actual
	-rm results.csv
