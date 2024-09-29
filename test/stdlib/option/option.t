  $ lexa ./option.lx -o main --output-c &> /dev/null
  $ ./main
  OK

  $ lexa ./option_get_fail.lx -o main --output-c &> /dev/null
  $ ./main
  Error: option is None
  [1]
