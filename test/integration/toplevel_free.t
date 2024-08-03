  $ sstal ../lexi_snippets/toplevel_free.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main
