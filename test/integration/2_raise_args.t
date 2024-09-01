  $ lexa ../lexa_snippets/2_raise_args.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  10
  20
  0
  10
  20
  10
  20
