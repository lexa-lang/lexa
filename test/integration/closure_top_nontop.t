  $ sstal ../lexi_snippets/closure_top_nontop.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main 1
  3
  $ ./main 0
  1
