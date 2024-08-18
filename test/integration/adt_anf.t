  $ sstal ../lexi_snippets/adt/anf.lexi -o main.c
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
