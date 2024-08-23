  $ sstal ../lexi_snippets/closure_adder.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  12
  17
