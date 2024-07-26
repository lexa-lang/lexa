import matplotlib.pyplot as plt
import subprocess
import re
import argparse

IN_VAL_PLACEHOLDER = "IN"

EFFEKT_BENCH_MAIN = """
def main() = ignore[WrongFormat] {commandLineArgs() match {
  case Nil() => println("Expects one argument")
  case Cons(x, Nil()) =>
    val t = timed{ run(x.toInt) }
    println(show(t / 1000 / 1000))
  case other => println("Expects one argument, not '" ++ show(size(other)) ++ "'")
}
}
"""

def print_message(message):
    print(f"{'='*len(message)}\n{message}\n{'='*len(message)}")

def parse_output(output_file):
    pairs = []
    f = open(output_file, 'r')
    for line in f.readlines()[1:]:
        command = line.split(",")[0]
        n = int(re.search(r'\d+', command).group())
        mean_time = float(line.split(",")[1])
        pairs.append((n, mean_time))
    return pairs

def plot(result_file, title, plot_file, overhead):
    plt.figure(figsize=(6,6))

    n_values, runtimes = zip(*parse_output(result_file))
    runtimes = [r - overhead for r in runtimes]
    plt.plot(n_values, runtimes, marker='o', alpha=1)

    plt.xlabel('n')
    plt.ylabel('Runtime (seconds)')
    plt.title(title)
    plt.grid(True)
    plt.savefig(plot_file, dpi=600)

    print_message(f"\"{title}\" saved to {plot_file}")

def build_and_bench(path, build_command, run_command, max_input, result_file):
    print_message(f"Building {path}")
    subprocess.run(build_command, check=True, text=True, shell=True, cwd=path)
    print_message("Done building")
    print_message(f"Benchmarking {path}")
    benchmark_command = f"hyperfine --shell none --warmup 3 -P {IN_VAL_PLACEHOLDER} 0 {max_input} -D {int(max_input / 10)} --export-csv {result_file} '{run_command}'"
    subprocess.run(benchmark_command, check=True, text=True, shell=True, cwd=path)
    print_message("Done benchmarking")

def bench_warnup_overhead(path, run_command):
    print_message(f"Estimating warmup for {path}")
    run_command = "time " + run_command.replace(f"{{{IN_VAL_PLACEHOLDER}}}", "0")
    overheads = []
    for _ in range(100):
        out = subprocess.run(run_command, check=True, text=True, shell=True, cwd=path, capture_output=True)
        internal_nano = int(re.search(r"Nanosecond used: (\d+)", out.stdout).group(1))
        minutes, seconds = map(float, re.search(r"real\s+(\d+)m(\d+\.\d+)s", out.stderr).groups())
        external_sec = minutes * 60 + seconds
        overheads.append(external_sec * 1000 - internal_nano / 1e6)
    overheads = overheads[10:] # Discard first 10 runs
    overhead = sum(overheads) / len(overheads)
    print_message(f"Estimated warmup overhead: {overhead} ms")
    return overhead
    
def main():
    cmds = {
        "scheduler" : {
            "lexi" : {
                "build" : "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 3000,
            },
            "effekt" : {
                "build" : "effekt_latest.sh --backend js --compile main.effekt",
                # 0 in the run command is a dummy second argument to tell the program to measure its internal timing
                "run" : f"node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {{{IN_VAL_PLACEHOLDER}}} 0",
                "max_input" : 10,
                "adjust_warmup" : True
            },
            "koka" : {
                "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 3000,
            },
            "koka_named" : {
                "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 3000,
                "fail_reason" : "Koka internal compiler error",
            },
            "ocaml" : {
                "build" : "opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 100000,
            }
        }
    }
    for bench, sys_cmds in cmds.items():
        for sys, cmds in sys_cmds.items():
            if "fail_reason" in cmds:
                print_message(f"Skipping {sys} {bench} due to {cmds['fail_reason']}")
                continue
            path = f"../../benchmark-programs/{sys}/{bench}"
            result_file = f"{sys}_{bench}.csv"
            build_and_bench(path, cmds["build"], cmds["run"], cmds["max_input"], result_file)
            subprocess.run(f"cp {path}/{result_file} .", check=True, text=True, shell=True)
            overhead = 0
            if "adjust_warmup" in cmds:
                overhead = bench_warnup_overhead(path, cmds["run"])
            plot(result_file, f"{sys.capitalize()} {bench}", f"{sys}_{bench}.png", overhead)

if __name__ == "__main__":
    main()