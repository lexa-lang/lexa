  $ lexa ../lexa_snippets/closure_adder.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  12
  17
