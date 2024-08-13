  $ sstal ../lexi_snippets/closure_adder.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  12
  17
