  $ sstal ../lexi_snippets/lambdaman/lambdaman.lx -o main.c
  $ echo "$(cat ../lexi_snippets/lambdaman/API.h main.c)" > main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  UDRRURRLLDLLLLLDURRR
