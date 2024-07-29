import matplotlib.pyplot as plt
import subprocess
import re
import argparse
import os


def print_message(message):
    print(f"{'='*len(message)}\n{message}\n{'='*len(message)}")

benchmark_programs = ["countdown", "fibonacci_recursive", "product_early", "iterator", "nqueens", "tree_explore", "triples", "resume_nontail", "parsing_dollars", "handler_sieve", "scheduler", "interruptible_iterator"]
result_file = "runtimes.txt"

def parse_output(output_file):
    pairs = []
    f = open(output_file, 'r')
    for line in f.readlines()[1:]:
        command = line.split(",")[0]
        for name in benchmark_programs:
            if name in command:
                break
        mean_time = float(line.split(",")[1])
        pairs.append((name, mean_time))
    return pairs

platforms = ["lexi", "effekt", "koka", "koka_named", "ocaml"]

def test(platform):
    print_message(f"Testing {platform}...")
    make_command = f"cd ../benchmark-programs/{platform}/ && make test"
    subprocess.run(make_command, shell=True, check=True)
    print_message("Success.")

def bench(platform):
    print_message(f"Benchmarking {platform}...")
    make_command = f"cd ../benchmark-programs/{platform}/ && taskset -c 0 make bench"
    subprocess.run(make_command, shell=True, check=True)
    pairs = parse_output(f"../benchmark-programs/{platform}/results.csv")
    with open(result_file, "a") as f:
        f.write(f"========{platform}=========\n")
        for name, mean_time in pairs:
            f.write(f"{name} {(mean_time*1000):.1f}ms\n")
        f.write(f"========{platform}=========\n")
    print_message(f"Results saved to {result_file}")

def main():
    parser = argparse.ArgumentParser(description="Process the --kicktire argument")
    parser.add_argument('--kick-tire', action='store_true', help='Enable the kicktire option')
    
    args = parser.parse_args()
    
    if args.kick_tire:
        print_message("Kicktire mode enabled.")
        for platform in platforms:
            test(platform)
    else:
        if os.path.exists(result_file):
            os.remove(result_file)
        for platform in platforms:
            bench(platform)

    print_message("Done.")

if __name__ == "__main__":
    main()
