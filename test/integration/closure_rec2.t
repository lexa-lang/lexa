  $ sstal ../lexi_snippets/closure_rec2.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  100
  200
