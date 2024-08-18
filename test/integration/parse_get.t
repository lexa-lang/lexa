  $ sstal ../lexi_snippets/parse/get.lexa -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 
  42
