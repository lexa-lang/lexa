  $ sstal ../lexi_snippets/normal_dist.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main
  0.840188
  0.394383
  0.590135
  2.477981
  0.783099
  0.363503
