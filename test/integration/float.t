  $ sstal ../lexi_snippets/float.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main
  1.100000
  2.200000
  3.300000
  -1.100000
