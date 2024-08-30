  $ sstal ../../benchmarks/lexa/interruptible_iterator/main.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 10
  110000
