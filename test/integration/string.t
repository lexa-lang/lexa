  $ sstal ../lexi_snippets/string.lexa -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ ./main
  hello
  world
  escape sequences:
  
  	"\foobar
  length of foo is: 3
