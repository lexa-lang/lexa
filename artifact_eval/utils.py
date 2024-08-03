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

def bench(path, run_command, input, adjust_warmup):
    thread_id = int(current_thread().getName().split('_')[1])
    CPU = bench_CPUs[thread_id]
    print_message(f"Benchmarking {path}")
    # NB: use five spaces so that the command can be parsed out later
    taskset_cmd = f"taskset -c {CPU}     {{}}     "
    hyperfine_cmd = f"hyperfine --shell none --warmup 3 --time-unit millisecond '{taskset_cmd}'"
    command = hyperfine_cmd.format(run_command.format(IN=input))
    result = subprocess.run(command, check=True, text=True, capture_output=True, shell=True, cwd=path)
    time_mili = float(re.search(r"Time \(mean ± σ\):\s+(\d+\.\d+) ms", result.stdout).group(1))
    command = re.search(r"     (.*)     ", command).group(1)
    print_message("Done benchmarking")

    if adjust_warmup:
        warmup_overhead_mili = bench_warnup_overhead(path, run_command)
        time_mili -= warmup_overhead_mili
    return time_mili

def build_and_bench(path, build_command, run_command, input, adjust_warmup):
    build(path, build_command)
    return bench(path, run_command, input, adjust_warmup)

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


def main():
    config_tups = [(platform, benchmark, params) for (platform, benchmark), params in config.items()]
    config_tups.sort(key=lambda x: (platforms.index(x[0]), benchmarks.index(x[1])))

    results = []

    result_txt = "runtimes.txt"
    result_csv = "runtimes.csv"
    if os.path.exists(result_txt):
        os.rename(result_txt, result_txt + ".bak")
    if os.path.exists(result_csv):
        os.rename(result_csv, result_csv + ".bak")

    with ThreadPoolExecutor(max_workers=len(bench_CPUs)) as executor:
        results_generator = executor.map(
            lambda c: 
                (c[0], 
                c[1], 
                int(build_and_bench(f"../benchmark-programs/{c[0]}/{c[1]}", c[2]["build"], c[2]["run"], c[2]["bench_input"], c[2].get("adjust_warmup", False))
                    * c[2].get("scale", 1))
                )
                if "fail_reason" not in c[2] else (c[0], c[1], None),
            config_tups
        )
        with open(result_txt, 'w') as f:
            for platform, benchmark, time_mili in results_generator:
                results += [(platform, benchmark, time_mili)]
                f.write(f"{platform:<15} {benchmark:<30} {time_mili}\n")
                f.flush()

    import pandas as pd
    df = pd.DataFrame(results, columns=["platform", "benchmark", "time_mili"])
    pivoted_df = df.pivot_table(index="benchmark", columns="platform", values="time_mili", sort=False)
    pivoted_df.to_csv(result_csv)

if __name__ == "__main__":
    main()