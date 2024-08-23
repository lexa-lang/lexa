  $ sstal ../lexi_snippets/newref_expr.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  3
  5
