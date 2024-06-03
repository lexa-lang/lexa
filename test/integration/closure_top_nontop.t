  $ sstal ../lexi_snippets/closure_top_nontop.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main &> /dev/null
  $ ./main 1
  3
  $ ./main 0
  1
