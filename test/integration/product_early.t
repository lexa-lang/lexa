  $ sstal ../lexi/product_early/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  0
