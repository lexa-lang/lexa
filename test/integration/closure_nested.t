  $ sstal ../lexi_snippets/closure_nested.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  6
