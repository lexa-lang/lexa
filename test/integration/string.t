  $ sstal ../lexa_snippets/string.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  hello
  world
  escape sequences:
  
  	"\foobar
  length of foo is: 3
