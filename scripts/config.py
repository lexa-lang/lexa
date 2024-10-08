import os
import psutil
import pwd

# On my machine with i5-13600K, the 6 performance cores
# uses hyperthreading, so we have 6 physical cores as follow
with open('/proc/cpuinfo') as f:
    for line in f:
        if 'model name' in line:
            cpu_model = line.split(': ')[1].strip()
            break
if "i5-13600K" in cpu_model:
    bench_CPUs = ["0", "2", "4", "6", "8", "10"]
else:
    # list all the physical cores
    bench_CPUs = list(range(psutil.cpu_count()))
    if len(bench_CPUs) > 4:
        # do not use too much CI resources
        bench_CPUs = bench_CPUs[:4]

benchmarks = ["countdown", "fibonacci_recursive", "product_early", "iterator", "nqueens", "generator", "tree_explore", "triples", "resume_nontail", "parsing_dollars", "handler_sieve", "resume_nontail_2", "scheduler", "interruptible_iterator"]
platforms = ["lexa", "effekt", "koka_named", "koka", "ocaml"]

config = {}

for benchmark in benchmarks:
    LEXA_BUILD_COMMAND = "flock /tmp/dune_lockfile -c 'lexa main.lx -o main'"
    LEXA_RUN_COMMAND = "./main {IN}"
    config[("lexa", benchmark)] = {
        "build": LEXA_BUILD_COMMAND, "run": LEXA_RUN_COMMAND,
    }

    OCAML_BUILD_COMMAND = "flock /tmp/opam_lockfile -c 'opam exec --switch=5.3.0+trunk -- ocamlopt -O3 -o main -I $(opam var lib)/multicont multicont.cmxa main.ml -o main'"
    OCAML_RUN_COMMAND = "./main {IN}"
    config[("ocaml", benchmark)] = {
        "build": OCAML_BUILD_COMMAND, "run": OCAML_RUN_COMMAND,
    }

    KOKA_BUILD_COMMAND = "koka -O3 -v0 -o main main.kk  && chmod +x main"
    KOKA_RUN_COMMAND = "./main {IN}"
    config[("koka", benchmark)] = {
        "build": KOKA_BUILD_COMMAND, "run": KOKA_RUN_COMMAND,
    }

    KOKA_NAMED_BUILD_COMMAND = "koka -O3 -v0 -o main main.kk  && chmod +x main"
    KOKA_NAMED_RUN_COMMAND = "./main {IN}"
    config[("koka_named", benchmark)] = {
        "build": KOKA_NAMED_BUILD_COMMAND, "run": KOKA_NAMED_RUN_COMMAND,
    }

    EFFEKT_BUILD_COMMAND = "effekt_latest.sh --backend ml --compile main.effekt  && mlton -default-type int64 -output main out/main.sml"
    EFFEKT_RUN_COMMAND = "./main {IN}"
    config[("effekt", benchmark)] = {
        "build": EFFEKT_BUILD_COMMAND, "run": EFFEKT_RUN_COMMAND,
    }

# Adjustments
config[("effekt", "handler_sieve")]["build"] = "effekt_latest.sh --backend chez-lift --compile main.effekt"
config[("effekt", "handler_sieve")]["run"] = "scheme --script out/main.ss {IN} 0"
config[("effekt", "handler_sieve")]["adjust_warmup"] = True
config[("effekt", "generator")]["build"] = "effekt_latest.sh --backend chez-lift --compile main.effekt"
config[("effekt", "generator")]["run"] = "scheme --script out/main.ss {IN} 0"
config[("effekt", "generator")]["adjust_warmup"] = True
config[("effekt", "scheduler")]["build"] = "effekt_latest.sh --backend js --compile main.effekt"
config[("effekt", "scheduler")]["run"] = "node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {IN} 0"
config[("effekt", "scheduler")]["adjust_warmup"] = True
config[("effekt", "interruptible_iterator")]["build"] = "effekt_latest.sh --backend js --compile main.effekt"
config[("effekt", "interruptible_iterator")]["run"] = "node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {IN} 0"
config[("effekt", "interruptible_iterator")]["adjust_warmup"] = True

# Known Failures
config[("koka", "interruptible_iterator")]["fail_reason"] = "Koka type system limitation"
config[("koka_named", "scheduler")]["fail_reason"] = "Koka internal compiler error"
# config[("koka_named", "concurrent_search")]["fail_reason"] = "Koka internal compiler error"
# config[("effekt", "concurrent_search")]["fail_reason"] = "MLton typing error"

config[("effekt", "scheduler")]["scale"] = 1000
config[("effekt", "interruptible_iterator")]["scale"] = 1000
config[("ocaml", "interruptible_iterator")]["scale"] = 100
config[("koka", "resume_nontail_2")]["scale"] = 100
config[("koka_named", "resume_nontail_2")]["scale"] = 100

for platform in platforms:
    config[(platform, "countdown")]["bench_input"] = 200000000
    config[(platform, "fibonacci_recursive")]["bench_input"] = 42
    config[(platform, "product_early")]["bench_input"] = 100000
    config[(platform, "iterator")]["bench_input"] = 40000000
    config[(platform, "nqueens")]["bench_input"] = 12
    config[(platform, "generator")]["bench_input"] = 25
    config[(platform, "tree_explore")]["bench_input"] = 16
    config[(platform, "triples")]["bench_input"] = 300
    config[(platform, "resume_nontail")]["bench_input"] = 10000
    config[(platform, "parsing_dollars")]["bench_input"] = 20000
    config[(platform, "handler_sieve")]["bench_input"] = 60000
    config[(platform, "scheduler")]["bench_input"] = 3000
    config[(platform, "interruptible_iterator")]["bench_input"] = 3000
    # config[(platform, "concurrent_search")]["bench_input"] = 13
    config[(platform, "resume_nontail_2")]["bench_input"] = 10000