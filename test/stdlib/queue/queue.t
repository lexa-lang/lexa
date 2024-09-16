  $ lexa ./queue.lx -o main.c
  $ clang -O3 -I ../../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  OK
