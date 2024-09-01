  $ lexa ./anf.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 5
  (
  x
  =
  (
  A
  =
  42
  ;
  (
  B
  =
  (
  g
  A
  )
  ;
  (
  f
  B
  )
  )
  )
  ;
  x
  )
