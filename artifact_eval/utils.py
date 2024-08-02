import subprocess
from concurrent.futures import ThreadPoolExecutor
import re
import os

# On my machine with i5-13600K, the 6 performance cores
# uses hyperthreading, so we have 6 physical cores as follow
CPUs = ["0", "2", "4", "6", "8", "10"]

def print_message(message, short=False):
    if short:
        print(f"=> {message} <=")
    else:
        print(f"{'='*len(message)}\n{message}\n{'='*len(message)}")

def run_processes(commands, cwd, seq=False):
    if seq:
        results = []
        for command in commands:
            print_message(f"Running {command}", short=True)
            result = subprocess.run(command, check=True, text=True, capture_output=True, shell=True, cwd=cwd)
            results.append(result)
        return results
    else:
        with ThreadPoolExecutor(max_workers=len(CPUs)) as executor:
            results = executor.map(
                lambda c: 
                    subprocess.run(c, check=True, text=True, capture_output=True, shell=True, cwd=cwd), 
                commands)
        return results

def parse_output(output_file):
    pairs = []
    f = open(output_file, 'r')
    for line in f.readlines():
        command = line.split(",")[0]
        n = int(re.search(r'\d+', command).group())
        mean_time = float(line.split(",")[1])
        pairs.append((n, mean_time))
    return pairs

def build_and_bench(path, build_command, run_command, input):
    print_message(f"Building {path}")
    subprocess.run(build_command, check=True, text=True, shell=True, cwd=path)
    print_message("Done building")
    print_message(f"Benchmarking {path}")
    # NB: use five spaces so that the command can be parsed out later
    taskset_cmd = f"taskset -c {','.join(CPUs)}     {{}}     "
    hyperfine_cmd = f"hyperfine --shell none --warmup 0 -M 2 --time-unit millisecond '{taskset_cmd}'"
    command = hyperfine_cmd.format(run_command.format(IN=input))
    result = run_processes([command], path, seq=True)[0]
    time_mili = re.search(r"Time \(mean ± σ\):\s+(\d+\.\d+) ms", result.stdout).group(1)
    command = re.search(r"     (.*)     ", command).group(1)
    print_message("Done benchmarking")
    return float(time_mili)


def build_and_bench_seq(path, build_command, run_command, max_input, num_input, result_file):
    print_message(f"Building {path}")
    subprocess.run(build_command, check=True, text=True, shell=True, cwd=path)
    print_message("Done building")
    print_message(f"Benchmarking {path}")
    # NB: use five spaces so that the command can be parsed out later
    taskset_cmd = f"taskset -c {','.join(CPUs)}     {{}}     "
    hyperfine_cmd = f"hyperfine --shell none --warmup 3 --time-unit second '{taskset_cmd}'"
    commands = [hyperfine_cmd.format(run_command.replace(f"{{{IN_VAL_PLACEHOLDER}}}", str(i))) for i in range(0, max_input, int(max_input / num_input))]
    results = run_processes(commands, path, seq=True)
    with open(result_file, 'w') as f:
        for command, result in zip(commands, results):
            time_mili = re.search(r"Time \(mean ± σ\):\s+(\d+\.\d+) s", result.stdout).group(1)
            command = re.search(r"     (.*)     ".format(IN_VAL_PLACEHOLDER), command).group(1)
            f.write(f"{command}, {time_mili}\n")
    print_message("Done benchmarking")

def bench_warnup_overhead(path, run_command):
    print_message(f"Estimating warmup for {path}")
    run_command = "time " + run_command.replace("{IN}", "0")
    overheads_mili = []
    for _ in range(100):
        out = subprocess.run(run_command, check=True, text=True, shell=True, cwd=path, capture_output=True)
        internal_nano = int(re.search(r"Nanosecond used: (\d+)", out.stdout).group(1))
        minutes, seconds = map(float, re.search(r"real\s+(\d+)m(\d+\.\d+)s", out.stderr).groups())
        external_sec = minutes * 60 + seconds
        overheads_mili.append(external_sec * 1000 - internal_nano / 1e6)
    overheads_mili = overheads_mili[10:] # Discard first 10 runs
    overhead = sum(overheads_mili) / len(overheads_mili)
    print_message(f"Estimated warmup overhead: {overhead} ms")
    return overhead


config = {}
benchmarks = ["countdown", "fibonacci_recursive", "product_early", "iterator", "nqueens", "tree_explore", "triples", "resume_nontail", "parsing_dollars", "handler_sieve", "scheduler", "interruptible_iterator"]
for benchmark in benchmarks:
    LEXI_BUILD_COMMAND = "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main"
    LEXI_RUN_COMMAND = "./main {IN}"
    config[("lexi", benchmark)] = {
        "build": LEXI_BUILD_COMMAND, "run": LEXI_RUN_COMMAND,
    }

    OCAML_BUILD_COMMAND = "opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml"
    OCAML_RUN_COMMAND = "./main {IN}"
    config[("ocaml", benchmark)] = {
        "build": OCAML_BUILD_COMMAND, "run": OCAML_RUN_COMMAND,
    }

    KOKA_BUILD_COMMAND = "koka -O3 -v0 -o main main.kk ; chmod +x main"
    KOKA_RUN_COMMAND = "./main {IN}"
    config[("koka", benchmark)] = {
        "build": KOKA_BUILD_COMMAND, "run": KOKA_RUN_COMMAND,
    }

    KOKA_NAMED_BUILD_COMMAND = "koka -O3 -v0 -o main main.kk ; chmod +x main"
    KOKA_NAMED_RUN_COMMAND = "./main {IN}"
    config[("koka_named", benchmark)] = {
        "build": KOKA_NAMED_BUILD_COMMAND, "run": KOKA_NAMED_RUN_COMMAND,
    }

    EFFEKT_BUILD_COMMAND = "effekt_latest.sh --backend ml --compile main.effekt ; mlton -default-type int64 -output main out/main.sml"
    EFFEKT_RUN_COMMAND = "./main {IN}"
    config[("effekt", benchmark)] = {
        "build": EFFEKT_BUILD_COMMAND, "run": EFFEKT_RUN_COMMAND,
    }

# Adjustments
config[("effekt", "handler_sieve")]["build"] = "effekt_latest.sh --backend chez-lift --compile main.effekt"
config[("effekt", "handler_sieve")]["run"] = "scheme --script out/main.ss {IN} 0"
config[("effekt", "handler_sieve")]["adjust_warmup"] = True
config[("effekt", "scheduler")]["build"] = "effekt_latest.sh --backend js --compile main.effekt"
config[("effekt", "scheduler")]["run"] = "node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {IN} 0"
config[("effekt", "scheduler")]["adjust_warmup"] = True
config[("effekt", "interruptible_iterator")]["build"] = "effekt_latest.sh --backend js --compile main.effekt"
config[("effekt", "interruptible_iterator")]["run"] = "node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {IN} 0"
config[("effekt", "interruptible_iterator")]["adjust_warmup"] = True

# Known Failures
config[("koka", "interruptible_iterator")]["fail_reason"] = "Koka internal compiler error"
config[("koka_named", "scheduler")]["fail_reason"] = "Koka internal compiler error"
config[("ocaml", "interruptible_iterator")]["fail_reason"] = "Not implemented"

platforms = ["lexi", "effekt", "koka", "koka_named", "ocaml"]
for platform in platforms:
    config[(platform, "countdown")]["bench_input"] = 200000000
    config[(platform, "fibonacci_recursive")]["bench_input"] = 42
    config[(platform, "product_early")]["bench_input"] = 100000
    config[(platform, "iterator")]["bench_input"] = 40000000
    config[(platform, "nqueens")]["bench_input"] = 12
    config[(platform, "tree_explore")]["bench_input"] = 16
    config[(platform, "triples")]["bench_input"] = 300
    config[(platform, "resume_nontail")]["bench_input"] = 10000
    config[(platform, "parsing_dollars")]["bench_input"] = 20000
    config[(platform, "handler_sieve")]["bench_input"] = 60000
    config[(platform, "scheduler")]["bench_input"] = 3000
    config[(platform, "interruptible_iterator")]["bench_input"] = 3000

config_tups = [(platform, benchmark, params) for (platform, benchmark), params in config.items()]
config_tups.sort(key=lambda x: (platforms.index(x[0]), benchmarks.index(x[1])))

results = []

result_file = "runtimes.txt"
if os.path.exists(result_file):
    os.rename(result_file, result_file + ".bak")
f = open(result_file, "w")

for platform, benchmark, params in config_tups:
    if platform != "ocaml":
        continue
    wanted_benchmarks = ["countdown", "fibonacci_recursive", "product_early", "iterator", "nqueens", "tree_explore", "triples", "resume_nontail", "parsing_dollars", "handler_sieve", "scheduler", "interruptible_iterator"]
    # wanted_benchmarks = ["interruptible_iterator"]
    if benchmark not in wanted_benchmarks:
        continue
    if "fail_reason" in params:
        print_message(f"Skipping {platform} {benchmark} due to {params['fail_reason']}")
        continue
    time_mili = build_and_bench(
        path=f"../benchmark-programs/{platform}/{benchmark}",
        build_command=params["build"],
        run_command=params["run"],
        input=params["bench_input"]
    )
    if "adjust_warmup" in params:
        warmup_overhead_mili = bench_warnup_overhead(
            path=f"../benchmark-programs/{platform}/{benchmark}",
            run_command=params["run"]
        )
        time_mili -= warmup_overhead_mili
    results.append((platform, benchmark, time_mili))
    f.write(f"{platform:<15} {benchmark:<30} {time_mili}\n")
    f.flush()