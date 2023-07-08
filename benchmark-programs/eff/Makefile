bench: build
	hyperfine --warmup 3 --export-csv results.csv \
		'countdown/main 200000000' \
		'fibonacci_recursive/main 42' \
		'product_early/main 100000' \
		'iterator/main 40000000' \
		'nqueens/main 12' \
		'tree_explore/main 16' \
		'triples/main 300 300' \
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
	cd countdown ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd fibonacci_recursive ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd product_early ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd iterator ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd nqueens ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd tree_explore ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd triples ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd parsing_dollars ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml
	cd resume_nontail ; cp ../OcamlHeader.ml OcamlHeader.ml ; eff.exe --no-stdlib --compile-plain-ocaml main.eff | opam exec -- ocamlformat - --name=temp.ml --enable-outside-detected-project > generated.ml ; opam exec -- ocamlopt -O3 -o main OcamlHeader.ml generated.ml wrapper.ml

clean:
	-rm */main
	-rm */generated.ml
	-rm */generated.cmi
	-rm */generated.o
	-rm */generated.cmx
	-rm */wrapper.cmi
	-rm */wrapper.o
	-rm */wrapper.cmx
	-rm */OcamlHeader.ml
	-rm */OcamlHeader.cmi
	-rm */OcamlHeader.o
	-rm */OcamlHeader.cmx
	-rm */expected
	-rm */actual
	-rm results.csv
