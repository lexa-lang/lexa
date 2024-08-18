  $ sstal ../lexi_snippets/string.lexa -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  hello
  world
  escape sequences:
  
  	"\foobar
  length of foo is: 3
