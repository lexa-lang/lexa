  $ sstal ../lexi/parsing_dollars/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 10
  55