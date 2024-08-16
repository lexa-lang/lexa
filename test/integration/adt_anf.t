  $ sstal ../lexi_snippets/adt/anf.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
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
