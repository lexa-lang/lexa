  $ sstal ../lexi_snippets/resume_expr_arg.lexi -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main 0
  20
  $ ./main 1
  10
