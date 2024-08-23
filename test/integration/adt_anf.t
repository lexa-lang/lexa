  $ sstal ../lexi_snippets/adt/anf.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
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
