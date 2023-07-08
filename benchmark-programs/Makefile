LANGS = eff effekt koka ocaml sml

all:
	@for LANG in $(LANGS); do\
		echo "Benchmarking $${LANG}...";\
		make -s -C $${LANG};\
		echo "...done!\n";\
	done

test:
	@for LANG in $(LANGS); do\
		echo "Testing $${LANG}...";\
		make -s -C $${LANG} test;\
		echo "...successful!\n";\
	done

show:
	@for LANG in $(LANGS); do\
		cp $${LANG}/results.csv $${LANG}_results.csv;\
		echo "### $${LANG}" | tee -a results.md;\
		csvlook --max-columns 4 $${LANG}_results.csv | tee -a results.md;\
		echo | tee -a results.md;\
	done

clean:
	@for LANG in $(LANGS); do\
		make -C $${LANG} clean;\
	done
