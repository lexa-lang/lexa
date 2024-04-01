#include <defs.h>

i64 prime1(i64 env, i64 e) {
    i64 i = ((i64*)env)[0];
    i64 prime_stub = ((i64*)env)[3];
    if (e % i == 0) {
        return 0;
    } else {
        return RAISE(prime_stub, 0, (e));
    }
}

static i64 body1(i64 prime_stub);

// NOTE: declare functions with `static` sometimes helps the compiler to optimize the code
static i64 primes(i64 prime_stub, i64 i, i64 n, i64 a){
    if (i >= n) {
        return a;
    } else {
        if (RAISE(prime_stub, 0, (i))) {
            return HANDLE(body1, ({TAIL, (void*)prime1}), (i, n, a, prime_stub));
        } else {
            return primes(prime_stub, i + 1, n, a);
        }
    }
}

static i64 body1(i64 prime_stub) {
    i64 i = ((meta_t*)prime_stub)->env[0];
    i64 n = ((meta_t*)prime_stub)->env[1];
    i64 a = ((meta_t*)prime_stub)->env[2];
    return primes(prime_stub, i + 1, n, a + i);
}

i64 prime2(i64 env, i64 e) {
    return 1;
}

static i64 body2(i64 prime_stub) {
    i64 n = ((meta_t*)prime_stub)->env[0];
    return primes(prime_stub, 2, n, 0);
}

static i64 run(i64 n){
    return HANDLE(body2, ({TAIL, (void*)prime2}), (n));
}

int main(int argc, char *argv[]){
    printInt(run(readInt()));
    return 0;
}