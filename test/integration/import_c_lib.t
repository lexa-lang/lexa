  $ echo "the quick brown fox jumps over the lazy dog" > a.txt
  $ lexa ../lexa_snippets/import_c_lib/file.lx -o main --output-c &> /dev/null
  $ ./main
  File Content:
  the quick brown fox jumps over the lazy dog
