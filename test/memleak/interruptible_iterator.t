  $ sstal ../lexi/interruptible_iterator/main.ir -o main.c
  $ clang -O3 -I ../stacktrek -I ../gc/include main.c ../gc/lib/libgc.so -o main -lm -Wl,-R../gc/lib &> /dev/null
  $ valgrind  --leak-check=full --error-exitcode=2 --undef-value-errors=no --quiet --suppressions=suppress.supp ./main 10 &> /dev/null
  $ echo $?
  0