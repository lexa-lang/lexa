  $ sstal ../lexi_snippets/closure_call.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main 14
  10
  $ ./main 0
  4
