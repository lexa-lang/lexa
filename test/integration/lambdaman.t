  $ sstal ../lexi_snippets/lambdaman/lambdaman.lexi -o main.c
  $ echo "$(cat ../lexi_snippets/lambdaman/API.h main.c)" > main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main
  UDRRURRLLDLLLLLDURRR
