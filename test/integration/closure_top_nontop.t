  $ lexa ../lexa_snippets/closure_top_nontop.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 1
  3
  $ ./main 0
  1
