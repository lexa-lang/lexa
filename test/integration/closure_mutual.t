  $ sstal ../lexi_snippets/closure_mutual.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 6
  1
  $ ./main 0
  1
  $ ./main 99
  0
  $ ./main 42
  1
