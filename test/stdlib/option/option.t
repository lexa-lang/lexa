  $ lexa ./option.lx -o main.c
  $ clang -O3 -I ../../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  OK

  $ lexa ./option_get_fail.lx -o main.c
  $ clang -O3 -I ../../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  Error: option is None
  [1]
