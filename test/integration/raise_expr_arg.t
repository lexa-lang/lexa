  $ sstal ../lexi_snippets/raise_expr_arg.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 1
  10
  $ ./main 0
  20
