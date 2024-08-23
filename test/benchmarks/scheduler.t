  $ sstal ../../benchmarks/lexi/scheduler/main.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main 10
  10000
