  $ sstal ../lexi_snippets/raise_expr_arg.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main 1
  10
  $ ./main 0
  20
