  $ sstal ../lexi_snippets/adt/list.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
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
