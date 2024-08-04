import subprocess
from concurrent.futures import ThreadPoolExecutor
from threading import current_thread
import re
import os

from config import config, platforms, benchmarks, bench_CPUs

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
        with ThreadPoolExecutor(max_workers=len(bench_CPUs)) as executor:
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

def build(path, build_command):
    thread_id = int(current_thread().getName().split('_')[1])
    CPU = bench_CPUs[thread_id]
    print_message(f"Building {path}")
    taskset_cmd = f"taskset -c {CPU} {build_command}"
    subprocess.run(taskset_cmd, check=True, text=True, capture_output=True, shell=True, cwd=path)
    print_message("Done building")

def bench(path, run_command, input, adjust_warmup, quick=False):
    thread_id = int(current_thread().getName().split('_')[1])
    CPU = bench_CPUs[thread_id]
    print_message(f"Benchmarking {path}")
    if quick:
        hyperfine_cmd = f"hyperfine --shell none --warmup 0 -M 2 --time-unit millisecond '{run_command.format(IN=input)}'"
    else:
        hyperfine_cmd = f"hyperfine --shell none --warmup 5 --min-runs 30 --time-unit millisecond '{run_command.format(IN=input)}'"
    # NB: use five spaces so that the command can be parsed out later
    taskset_cmd = f"taskset -c {CPU} {hyperfine_cmd} "
    result = subprocess.run(taskset_cmd, check=True, text=True, capture_output=True, shell=True, cwd=path)
    time_mili = float(re.search(r"Time \(mean ± σ\):\s+(\d+\.\d+) ms", result.stdout).group(1))
    print_message(f"Done benchmarking {path}")

    if adjust_warmup:
        warmup_overhead_mili = bench_warnup_overhead(path, run_command, CPU)
        time_mili -= warmup_overhead_mili
    return time_mili

def build_and_bench(path, build_command, run_command, input, adjust_warmup, quick=False):
    build(path, build_command)
    return bench(path, run_command, input, adjust_warmup, quick)

def bench_warnup_overhead(path, run_command, CPU):
    print_message(f"Estimating warmup for {path}")
    run_command = "time " + run_command.format(IN=0)
    taskset_cmd = f"taskset -c {CPU} {run_command}"
    overheads_mili = []
    for _ in range(100):
        out = subprocess.run(taskset_cmd, check=True, text=True, shell=True, cwd=path, capture_output=True)
        internal_nano = int(re.search(r"Nanosecond used: (\d+)", out.stdout).group(1))
        external_sec = float(re.search(r"(\d+\.\d+)user", out.stderr).group(1))
        overheads_mili.append(external_sec * 1000 - internal_nano / 1e6)
    overheads_mili = overheads_mili[10:] # Discard first 10 runs
    overhead = sum(overheads_mili) / len(overheads_mili)
    print_message(f"Estimated warmup overhead: {overhead} ms")
    return overhead
