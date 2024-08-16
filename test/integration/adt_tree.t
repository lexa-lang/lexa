  $ sstal ../lexi_snippets/adt/tree.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main 5
  5
  4
  3
  2
  1
  1
  2
  1
  1
  3
  2
  1
  1
  2
  1
  1
  4
  3
  2
  1
  1
  2
  1
  1
  3
  2
  1
  1
  2
  1
  1
