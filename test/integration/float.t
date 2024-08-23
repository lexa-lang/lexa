  $ sstal ../lexi_snippets/float.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  1.100000
  2.200000
  3.300000
  -1.100000
