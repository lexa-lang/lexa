  $ sstal ../lexi_snippets/hello.lx -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  hello
  42
