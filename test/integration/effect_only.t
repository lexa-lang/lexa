  $ sstal ../lexa_snippets/effect_only.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm &> /dev/null
  $ ./main
  42
  43
  44
