  $ sstal ../lexi_snippets/closure_call.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 14
  10
  $ ./main 0
  4