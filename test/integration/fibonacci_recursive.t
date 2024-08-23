  $ sstal ../lexi/fibonacci_recursive/main.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  5
