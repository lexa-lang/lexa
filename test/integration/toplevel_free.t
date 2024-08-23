  $ sstal ../lexi_snippets/toplevel_free.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
