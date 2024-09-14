  $ echo "the quick brown fox jumps over the lazy dog" > a.txt
  $ lexa ../lexa_snippets/import_c_lib/file.lx -o main.c
  $ clang -O3 -I ../../src/stacktrek main.c -o main -lm -lgc &> /dev/null
  $ ./main
  File Content:
  the quick brown fox jumps over the lazy dog
