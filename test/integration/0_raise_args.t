  $ sstal ../lexa_snippets/0_raise_args.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  10
  20
  0
  10
  20
  30
  10
  20
  30
