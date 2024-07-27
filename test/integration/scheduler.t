  $ sstal ../lexi/scheduler/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 10
  1000
