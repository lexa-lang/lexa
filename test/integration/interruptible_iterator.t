  $ sstal ../lexi/interruptible_iterator/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 10
  110000
