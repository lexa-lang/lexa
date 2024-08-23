  $ sstal ../lexa_snippets/nested_expr.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  22
