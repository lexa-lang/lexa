  $ sstal ../lexi_snippets/newref_expr.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main
  3
  5
