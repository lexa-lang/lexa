  $ sstal ../lexi/countdown/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 5
  0
