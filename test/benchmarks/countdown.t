  $ sstal ../../benchmarks/lexi/countdown/main.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  0