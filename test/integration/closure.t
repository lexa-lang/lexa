  $ sstal ../lexi_test/closure.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 5
  1
