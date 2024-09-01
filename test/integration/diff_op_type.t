  $ lexa ../lexa_snippets/diff_op_type.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 5
  0
