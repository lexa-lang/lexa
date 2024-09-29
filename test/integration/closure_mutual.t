  $ lexa ../lexa_snippets/closure_mutual.lx -o main --output-c &> /dev/null
  $ ./main 6
  1
  $ ./main 0
  1
  $ ./main 99
  0
  $ ./main 42
  1
