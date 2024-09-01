  $ lexa ../lexa_snippets/resume_expr_arg.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main 0
  20
  $ ./main 1
  10
