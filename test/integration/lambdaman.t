  $ sstal ../lexa_snippets/lambdaman/lambdaman.lx -o main.c
  $ echo "$(cat ../lexa_snippets/lambdaman/API.h main.c)" > main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  UDRRURRLLDLLLLLDURRR
