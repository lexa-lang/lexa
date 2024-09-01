  $ lexa ../lexa_snippets/3_raise_args.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  10
  20
  30
  0
  10
  20
  30
  10
  20
  30
