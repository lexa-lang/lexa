  $ sstal ../lexi_snippets/lambdaman/lambdaman.lexi -o main.c
  $ echo "$(cat ../lexi_snippets/lambdaman/API.h main.c)" > main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main
  UDRRURRLLDLLLLLDURRR
