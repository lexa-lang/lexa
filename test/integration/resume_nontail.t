  $ sstal ../lexi/resume_nontail/main.ir -o main.c
  $ clang -O3 -I ../stacktrek main.c -o main -lm &> /dev/null
  $ ./main 5
  37
