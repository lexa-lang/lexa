  $ lexa ../lexa_snippets/closure_call.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 14
  10
  $ ./main 0
  4
