#include <stdint.h>

typedef enum {
    SINGLESHOT = 1 << 0,
    MULTISHOT = 1 << 1,
    TAIL = 1 << 2,
    ABORT = 1 << 3
} handler_mode_t;

typedef struct {
  handler_mode_t mode;
  void *func;
} handler_def_t;

typedef struct {
  // HACK: sp_exchanger stores the address of _sp_exchanger. We use this indirection
  // to convince the compiler that this struct is immutable, so optimization such as
  // argpromotion can proceed.
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[];
} m_1op_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[0];
} m_1op0env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[1];
} m_1op1env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[2];
} m_1op2env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[3];
} m_1op3env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[];
} m_2op_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[0];
} m_2op0env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[1];
} m_2op1env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[2];
} m_2op2env_t;

typedef struct {
  void** sp_exchanger;
  handler_def_t* defs;
  intptr_t* env;
  void* _sp_exchanger[1];
  intptr_t _env[3];
} m_2op3env_t;