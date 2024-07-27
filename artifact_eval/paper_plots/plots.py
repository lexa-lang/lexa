import matplotlib.pyplot as plt
import subprocess
from concurrent.futures import ThreadPoolExecutor
import re
import argparse

# On my machine with i5-13600K, the 6 performance cores
# uses hyperthreading, so we have 6 physical cores as follow
CPUs = ["0", "2", "4", "6", "8", "10"]

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

def plot(result_file, title, plot_file, overhead_sec):
    plt.figure(figsize=(6,6))

    n_values, runtimes = zip(*parse_output(result_file))
    runtimes = [r - overhead_sec for r in runtimes]
    plt.plot(n_values, runtimes, marker='o', alpha=1)

    plt.xlabel('n')
    plt.ylabel('Runtime (seconds)')
    plt.title(title)
    plt.grid(True)
    plt.savefig(plot_file, dpi=600)

    print_message(f"\"{title}\" saved to {plot_file}")

def build_and_bench(path, build_command, run_command, max_input, num_input, result_file):
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
            time_sec = re.search(r"Time \(mean ± σ\):\s+(\d+\.\d+) s", result.stdout).group(1)
            command = re.search(r"     (.*)     ".format(IN_VAL_PLACEHOLDER), command).group(1)
            f.write(f"{command}, {time_sec}\n")
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
            # "lexi" : {
            #     "build" : "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 3000,
            # },
            # "effekt" : {
            #     "build" : "effekt_latest.sh --backend js --compile main.effekt",
            #     # 0 in the run command is a dummy second argument to tell the program to measure its internal timing
            #     "run" : f"node --eval \"require(\'\"\'./out/main.js\'\"\').main()\" -- _ {{{IN_VAL_PLACEHOLDER}}} 0",
            #     "max_input" : 3000,
            #     "adjust_warmup" : True
            # },
            # "koka" : {
            #     "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 3000,
            # },
            # "koka_named" : {
            #     "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 3000,
            #     "fail_reason" : "Koka internal compiler error",
            # },
            "ocaml" : {
                "build" : "opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml",
                "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
                "max_input" : 1000,
            }
        },


        "resume_nontail_with_stack_growth" : {
            # "lexi" : {
            #     "build" : "dune exec -- sstal main.ir -o main.c; clang -O3 -g -I ../../../stacktrek main.c -o main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 60000,
            # },
            # "effekt" : {
            #     "build" : "effekt_latest.sh --backend ml --compile main.effekt",
            #     # 0 in the run command is a dummy second argument to tell the program to measure its internal timing
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 60000,
            # },
            # "koka" : {
            #     "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 1000,
            # },
            # "koka_named" : {
            #     "build" : "koka -O3 -v0 -o main main.kk ; chmod +x main",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 1000,
            # },
            # "ocaml" : {
            #     "build" : "opam exec --switch=4.12.0+domains+effects -- ocamlopt -O3 -o main main.ml",
            #     "run" : f"./main {{{IN_VAL_PLACEHOLDER}}}",
            #     "max_input" : 40000,
            # }
        }
    }
    for bench, sys_cmds in cmds.items():
        for sys, cmds in sys_cmds.items():
            if "fail_reason" in cmds:
                print_message(f"Skipping {sys} {bench} due to {cmds['fail_reason']}")
                continue
            path = f"../../benchmark-programs/{sys}/{bench}"
            result_file = f"{sys}_{bench}.csv"
            num_input = 10
            build_and_bench(path, cmds["build"], cmds["run"], cmds["max_input"], num_input, result_file)
            overhead_sec = 0
            if "adjust_warmup" in cmds:
                overhead_sec = bench_warnup_overhead(path, cmds["run"])
            plot(result_file, f"{sys.capitalize()} {bench}", f"{sys}_{bench}.png", overhead_sec)

if __name__ == "__main__":
    main()