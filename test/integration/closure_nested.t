  $ sstal ../lexa_snippets/closure_nested.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  6
