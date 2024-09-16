  $ lexa ../lexa_snippets/import_c_lib/file.lx -o main.c
  $ cat ./main.c
  #include <datastructure.h>
  #include <stacktrek.h>
  #include <stdbool.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  
  #include "stdio.h"
  #include "unistd.h"
  int main(int argc, char *argv[]) {
    init_stack_pool();
  
    i64 __res__ = ({
      i64 file = (i64)(((i64(*)(i64, i64))fopen)(
          (int64_t)(({
            i64 *__s__ = (i64 *)xmalloc(8 * sizeof(char));
            strcpy((char *)__s__, "./a.txt");
            __s__;
          })),
          (int64_t)(({
            i64 *__s__ = (i64 *)xmalloc(2 * sizeof(char));
            strcpy((char *)__s__, "r");
            __s__;
          }))));
      ({
        ((file == 0) ? ((i64)(error((char *)(({
          i64 *__s__ = (i64 *)xmalloc(22 * sizeof(char));
          strcpy((char *)__s__, "Error opening file.\n");
          __s__;
        })))))
                     : 0);
        ({
          (((i64(*)(i64, i64, i64))fseek)((int64_t)file, (int64_t)0, (int64_t)2));
          ({
            i64 file_size = (i64)(((i64(*)(i64))ftell)((int64_t)file));
            ({
              (((i64(*)(i64))rewind)((int64_t)file));
              ({
                i64 buffer =
                    (i64)(((i64(*)(i64))malloc)((int64_t)((file_size + 1) * 8)));
                ({
                  ((buffer == 0) ? ((i64)(error((char *)(({
                    i64 *__s__ = (i64 *)xmalloc(28 * sizeof(char));
                    strcpy((char *)__s__, "Memory allocation failed.\n");
                    __s__;
                  })))))
                                 : 0);
                  ({
                    (((i64(*)(i64, i64, i64, i64))fread)(
                        (int64_t)buffer, (int64_t)8, (int64_t)file_size,
                        (int64_t)file));
                    ({
                      (((i64 *)buffer)[file_size] = 0);
                      ({
                        (((i64(*)(i64, i64))printf)(
                            (int64_t)(({
                              i64 *__s__ = (i64 *)xmalloc(18 * sizeof(char));
                              strcpy((char *)__s__, "File Content:\n%s");
                              __s__;
                            })),
                            (int64_t)buffer));
                        ({
                          (((i64(*)(i64))fclose)((int64_t)file));
                          0;
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
    destroy_stack_pool();
    return ((int)__res__);
  }
