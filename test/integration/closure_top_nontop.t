  $ sstal ../lexi_snippets/closure_top_nontop.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main 1
  3
  $ ./main 0
  1
