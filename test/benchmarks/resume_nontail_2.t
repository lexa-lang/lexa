  $ sstal ../../benchmarks/lexi/resume_nontail_2/main.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  487