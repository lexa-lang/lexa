  $ lexa ../lexa_snippets/closure_mutual.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 6
  1
  $ ./main 0
  1
  $ ./main 99
  0
  $ ./main 42
  1
