  $ lexa ../lexa_snippets/import/use_list.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  3
  2
  1
  2
  1
  1
