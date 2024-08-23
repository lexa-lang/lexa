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
		'scheme --script handler_sieve/out/main.ss 60000' \
		'node --eval "require('\''./scheduler/out/main.js'\'').main()" -- _ 3000' \
		'node --eval "require('\''./interruptible_iterator/out/main.js'\'').main()" -- _ 3000'

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
	cd handler_sieve ; scheme --script out/main.ss > actual ; echo 171848738 > expected ; diff expected actual
	cd scheduler ; node --eval "require('./out/main.js').main()" -- _ 10 > actual ; echo 10000 > expected ; diff expected actual
	cd interruptible_iterator ; node --eval "require('./out/main.js').main()" -- _ 10 > actual ; echo 110 > expected ; diff expected actual

build:
	echo "Building programs..."
	cd countdown ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd fibonacci_recursive ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd product_early ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd iterator ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd nqueens ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd tree_explore ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd triples ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd resume_nontail ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd parsing_dollars ; effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml
	cd handler_sieve ; effekt_latest.sh --backend chez-lift --compile main.effekt
	cd scheduler ; effekt_latest.sh --backend js --compile main.effekt
	cd interruptible_iterator ; effekt_latest.sh --backend js --compile main.effekt

clean:
	-rm -r */out/
	-rm */main
	-rm results.csv
	-rm */expected
	-rm */actual
