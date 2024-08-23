  $ sstal ../lexi_snippets/adt/list.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  10
  8
  6
  4
  2
  10
  8
  6
  4
  2
