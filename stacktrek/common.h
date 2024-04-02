#pragma once

#define DEBUG 1
#ifdef DEBUG
#define DEBUG_ATTRIBUTE __attribute__((noinline))
#else
#define DEBUG_ATTRIBUTE
#endif

#ifdef DEBUG
#define DEBUG_CODE(block) block
#else
#define DEBUG_CODE(block)
#endif


#define FAST_SWITCH
#ifdef FAST_SWITCH
typedef struct {
  void*     reg_ip;
  void*     reg_sp;
} jb_t;

#define SEAL_STACK(cont, sp) \
    __asm__ ( \
        "pushq %0\n\t" \
        "movq %%rsp, 0(%1)\n\t" \
        :: "r" (cont), "r" (sp) \
    )

#define UNSEAL_STACK(sp, ret_val) \
    __asm__ ( \
        "movq %0, %%rsp\n\t" \
        "retq\n\t" \
        :: "r" (sp), "a" (ret_val) \
    )

#define SAVE_CONTEXT(jb, cont) \
    __asm__ ( \
        "movq    %1,  0(%0)      \n\t" \
        "leaq    (%%rsp), %1      \n\t" \
        "movq    %1, 8(%0)    \n\t" \
        :: "r" (jb), "r" (&&cont) \
    )

#define RESTORE_CONTEXT(jb) \
    __asm__ ( \
        "movq 8(%0), %%rsp    \n\t" \
        "jmpq *(%0)            \n\t" \
        :: "r" (jb) \
    )

#define FAST_SWITCH_DECORATOR __attribute__((preserve_none))

#else
typedef struct {
  void*     reg_ip;
  int64_t   reg_rbx;
  void*     reg_sp;
  void*     reg_rbp;
  int64_t   reg_r12;
  int64_t   reg_r13;
  int64_t   reg_r14;
  int64_t   reg_r15;
} jb_t;

#define SAVE_CONTEXT(jb, cont) \
    __asm__ ( \
        "movq    %1,  0(%0)      \n\t" \
        "movq    %%rbx,  8(%0)    \n\t" \
        "leaq    (%%rsp), %1      \n\t" \
        "movq    %1, 16(%0)    \n\t" \
        "movq    %%rbp, 24(%0)    \n\t" \
        "movq    %%r12, 32(%0)    \n\t" \
        "movq    %%r13, 40(%0)    \n\t" \
        "movq    %%r14, 48(%0)    \n\t" \
        "movq    %%r15, 56(%0)    \n\t" \
        :: "r" (jb), "r" (&&cont) \
    )

#define RESTORE_CONTEXT(jb) \
    __asm__ ( \
        "movq  8(%0), %%rbx    \n\t" \
        "movq 16(%0), %%rsp    \n\t" \
        "movq 24(%0), %%rbp    \n\t" \
        "movq 32(%0), %%r12    \n\t" \
        "movq 40(%0), %%r13    \n\t" \
        "movq 48(%0), %%r14    \n\t" \
        "movq 56(%0), %%r15    \n\t" \
        "jmpq *(%0)            \n\t" \
        :: "r" (jb) \
    )

#define FAST_SWITCH_DECORATOR

#endif