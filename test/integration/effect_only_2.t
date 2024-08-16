  $ sstal ../lexi_snippets/effect_only_2.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main
  42
  42
