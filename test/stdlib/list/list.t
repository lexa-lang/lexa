  $ lexa ./list.lx -o main.c
  $ clang -O3 -I ../../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  OK

  $ lexa ./nth_error.lx -o main.c
  $ clang -O3 -I ../../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  Error: nth
  [1]
