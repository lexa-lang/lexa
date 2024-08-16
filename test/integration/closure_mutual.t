  $ sstal ../lexi_snippets/closure_mutual.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main 6
  1
  $ ./main 0
  1
  $ ./main 99
  0
  $ ./main 42
  1
