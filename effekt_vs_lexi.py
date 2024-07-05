import matplotlib.pyplot as plt
import subprocess
import re


with_tick = """
500 1.6575616904600001
1000 5.10894089662
1500 10.609629030159999
2000 18.23540060416
2500 28.18155229488
3000 40.54269849558
3500 55.951419425359994
4000 74.37121790876
4500 94.10668469864
5000 111.80604296888
"""

without_tick = """
500 5.594105127640001
1000 11.478034848899998
1500 17.29020170788
2000 23.33874772374
2500 29.09484809288
3000 34.96429950202
3500 41.38043868618
4000 51.41984537392
4500 59.41622735022
5000 66.30660741084
"""

input_range = range(100, 501, 100)

effekt_scheduler_build = "cd ./benchmark-programs/effekt/scheduler && effekt022.sh --backend js --compile main.effekt"
effekt_scheduler_run = "'node --eval \"require('\\''./benchmark-programs/effekt/scheduler/out/main.js'\\'').main()\" -- _ {}'"
effekt_result_file = "result_effekt_scheduler.csv"
effekt_scheduler_command = f"hyperfine --warmup 1 -M 1 --export-csv {effekt_result_file} " + " ".join([effekt_scheduler_run.format(i) for i in input_range])

effekt_scheduler_notick_build = "cd ./benchmark-programs/effekt/scheduler_notick && effekt022.sh --backend js --compile main.effekt"
effekt_scheduler_notick_run = "'node --eval \"require('\\''./benchmark-programs/effekt/scheduler_notick/out/main.js'\\'').main()\" -- _ {}'"
effekt_result_notick_file = "result_effekt_scheduler_notick.csv"
effekt_scheduler_notick_command = f"hyperfine --warmup 1 -M 1 --export-csv {effekt_result_notick_file} " + " ".join([effekt_scheduler_notick_run.format(i) for i in input_range])

try:
    # print("Building Effekt's Scheduler")
    # subprocess.run(effekt_scheduler_build, check=True, text=True, capture_output=True, shell=True)
    # print("Building Effekt's Scheduler without Tick")
    # subprocess.run(effekt_scheduler_notick_build, check=True, text=True, capture_output=True, shell=True)

    print("Running and benchmarking Effekt's Scheduler")
    subprocess.run(effekt_scheduler_command, check=True, text=True, shell=True)
    print("Running and benchmarking Effekt's Scheduler without Tick")
    print(effekt_scheduler_notick_command)
    subprocess.run(effekt_scheduler_notick_command, check=True, text=True, shell=True)
except subprocess.CalledProcessError as e:
    print(e.stderr)
    exit(1)

# lexi_scheduler_build = "cd ./benchmark-programs/lexi/scheduler && dune exec -- sstal main.ir -o main.c && clang-format -i main.c && clang -O3 -g -I ../../../stacktrek main.c -o main"
# lexi_scheduler_run = "'./benchmark-programs/lexi/scheduler/main {}'"
# lexi_result_file = "result_lexi_scheduler.csv"
# lexi_scheduler_command = f"hyperfine --warmup 3 --export-csv {lexi_result_file} " + " ".join([lexi_scheduler_run.format(i) for i in input_range])

# lexi_scheduler_notick_build = "cd ./benchmark-programs/lexi/scheduler_notick && dune exec -- sstal main.ir -o main.c && clang-format -i main.c && clang -O3 -g -I ../../../stacktrek main.c -o main"
# lexi_scheduler_notick_run = "'./benchmark-programs/lexi/scheduler_notick/main {}'"
# lexi_result_notick_file = "result_lexi_scheduler_notick.csv"
# lexi_scheduler_notick_command = f"hyperfine --warmup 3 --export-csv {lexi_result_notick_file} " + " ".join([lexi_scheduler_notick_run.format(i) for i in input_range])

# try:
#     print("Building Effekt's Scheduler")
#     subprocess.run(effekt_scheduler_build, check=True, text=True, capture_output=True, shell=True)
#     print("Building Lexi's Scheduler")
#     subprocess.run(lexi_scheduler_build, check=True, text=True, capture_output=True, shell=True)

#     print("Running and benchmarking Effekt's Scheduler")
#     subprocess.run(effekt_scheduler_command, check=True, text=True, shell=True)
#     print("Running and benchmarking Lexi's Scheduler")
#     subprocess.run(lexi_scheduler_command, check=True, text=True, shell=True)
# except subprocess.CalledProcessError as e:
#     print(e.stderr)

def parse_output(output_file):
    pairs = []
    f = open(output_file, 'r')
    for line in f.readlines()[1:]:
        command = line.split(",")[0]
        n = int(re.search(r'\d+', command).group())
        mean_time = float(line.split(",")[1])
        pairs.append((n, mean_time))

    return pairs

plt.figure(figsize=(5,5))
title = 'Effekt\'s Scheduler with and without Tick'
plot_file = "effekt-scheduler-with-and-without-tick.png"


n_values, runtimes = zip(*parse_output(effekt_result_file))
plt.plot(n_values, runtimes, marker='o', label='With Tick', alpha=1)

n_values, runtimes = zip(*parse_output(effekt_result_notick_file))
plt.plot(n_values, runtimes, marker='o', label='Without Tick', alpha=0.5)

plt.legend()
plt.xlabel('n')
plt.ylabel('Runtime (seconds)')
plt.title(title)
plt.grid(True)
plt.savefig(plot_file, dpi=300)