  $ sstal ../lexi_snippets/tail_fact.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  120
  120
