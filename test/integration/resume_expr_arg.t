  $ sstal ../lexi_snippets/resume_expr_arg.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 0
  20
  $ ./main 1
  10
