  $ sstal ../lexi_snippets/closure_rec.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main 6
  0
  6
  1
  5
  2
  4
  3
  3
  4
  2
  5
  1
  6
  0
