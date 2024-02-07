#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

int fibonacci(int n){
    if(n == 0){
        return 0;
    } else if(n == 1){
        return 1;
    } else {
        return fibonacci(n-1) + fibonacci(n-2);
    }
}

int main(int argc, char *argv[]){
    int out = fibonacci(atoi(argv[1]));
    printf("%d\n", out);
    return 0;
}