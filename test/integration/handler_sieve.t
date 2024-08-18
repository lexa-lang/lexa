  $ sstal ../lexi/handler_sieve/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 10
  17
