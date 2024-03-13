
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

intptr_t make_array()
{
    return (
        ({
            intptr_t s = (intptr_t)malloc(5 * sizeof(intptr_t));
            ({
                intptr_t _ = ((intptr_t *)s)[2] = 42;
                s;
            });
        }));
}
int main()
{
    return (
        (int)({
            intptr_t array = make_array();
            ((intptr_t *)array)[2];
        }));
}
