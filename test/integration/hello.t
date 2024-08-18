  $ sstal ../lexi_snippets/hello.lexi -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  hello
  42
