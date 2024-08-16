  $ sstal ../lexi_snippets/adt/list.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
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
