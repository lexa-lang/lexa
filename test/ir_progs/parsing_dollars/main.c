#include <datastructure.h>
#include <defs.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static i64 run(i64);
static i64 catch_action(i64, i64, i64);
static i64 sum_action(i64, i64);
static i64 feed_action(i64, i64, i64);
static i64 parse(i64, i64, i64, i64);
static i64 feed_body(i64, i64);
static i64 feed(i64, i64, i64, i64);
i64 read(i64 *);
static i64 catch (i64, i64, i64);
static i64 catch_body(i64, i64);
i64 stop(i64 *, i64);
static i64 sum(i64, i64);
static i64 sum_body(i64, i64);
i64 emit(i64 *, i64);
static i64 is_dollar(i64);
static i64 dollar();
static i64 is_newline(i64);
static i64 newline();

static i64 newline() { return (10); }

static i64 is_newline(i64 c) { return (c == 10); }

static i64 dollar() { return (36); }

static i64 is_dollar(i64 c) { return (c == 36); }

i64 emit(i64 *env, i64 e)
{
  i64 s_ref = (i64)(((i64 *)env)[1]);
  i64 s = (i64)(((i64 *)s_ref)[0]);
  i64 s_inc = (i64)(s + e);
  ((i64 *)s_ref)[0] = s_inc;
}

static i64 sum_body(i64 env, i64 emit_stub)
{
  i64 action = (i64)(((i64 *)env)[0]);
  i64 n = (i64)(((i64 *)env)[2]);
  return ((i64(*)(i64, i64))action)(emit_stub, n);
}

static i64 sum(i64 action, i64 n)
{
  i64 s = (i64)(({
    i64 temp = (i64)malloc(1 * sizeof(i64));
    ((i64 *)temp)[0] = (i64)0;
    temp;
  }));
  i64 _ = (i64)(HANDLE(sum_body, ({TAIL, emit}), (action, s, n)));
  return ((i64 *)s)[0];
}

i64 stop(i64 *env, i64 _) { return (0); }

static i64 catch_body(i64 env, i64 stop_stub)
{
  i64 action = (i64)(((i64 *)env)[0]);
  i64 emit_stub = (i64)(((i64 *)env)[1]);
  i64 n = (i64)(((i64 *)env)[2]);
  return ((i64(*)(i64, i64, i64))action)(stop_stub, emit_stub, n);
}

static i64 catch (i64 action, i64 emit_stub, i64 n)
{
  return (HANDLE(catch_body, ({ABORT, stop}), (action, emit_stub, n)));
}

i64 read(i64 *env)
{
  i64 i_ref = (i64)(((i64 *)env)[1]);
  i64 j_ref = (i64)(((i64 *)env)[2]);
  i64 i = (i64)(((i64 *)i_ref)[0]);
  i64 j = (i64)(((i64 *)j_ref)[0]);
  i64 n = (i64)(((i64 *)env)[3]);
  i64 stop_stub = (i64)(((i64 *)env)[4]);
  if ((i64)(i > n))
  {
    return RAISEA(stop_stub, 0, (0));
  }
  else
  {
    if (j == 0)
    {
      i64 i_inc = (i64)(i + 1);
      i64 _ = (i64)(((i64 *)i_ref)[0] = i_inc);
      i64 __ = (i64)(((i64 *)j_ref)[0] = i_inc);
      return ((i64(*)())newline)();
    }
    else
    {
      i64 j_dec = (i64)(j - 1);
      i64 _ = (i64)(((i64 *)j_ref)[0] = j_dec);
      return ((i64(*)())dollar)();
    }
  }
}

static i64 feed(i64 n, i64 action, i64 stop_stub, i64 emit_stub)
{
  i64 i = (i64)(({
    i64 temp = (i64)malloc(1 * sizeof(i64));
    ((i64 *)temp)[0] = (i64)0;
    temp;
  }));
  i64 j = (i64)(({
    i64 temp = (i64)malloc(1 * sizeof(i64));
    ((i64 *)temp)[0] = (i64)0;
    temp;
  }));
  return HANDLE(feed_body, ({TAIL, read}),
                (action, i, j, n, stop_stub, emit_stub));
}

static i64 feed_body(i64 env, i64 read_stub)
{
  i64 action = (i64)(((i64 *)env)[0]);
  i64 stop_stub = (i64)(((i64 *)env)[4]);
  i64 emit_stub = (i64)(((i64 *)env)[5]);
  return ((i64(*)(i64, i64, i64))action)(read_stub, emit_stub, stop_stub);
}

static i64 parse(i64 a, i64 read_stub, i64 emit_stub, i64 stop_stub)
{
  i64 c = (i64)(RAISET(read_stub, 0, (0)));
  if (((i64(*)(i64))is_dollar)(c))
  {
    i64 a_inc = (i64)(a + 1);
    return ((i64(*)(i64, i64, i64, i64))parse)(a_inc, read_stub, emit_stub,
                                               stop_stub);
  }
  else
  {
    if (((i64(*)(i64))is_newline)(c))
    {
      i64 _ = (i64)(RAISET(emit_stub, 0, (a)));
      return ((i64(*)(i64, i64, i64, i64))parse)(0, read_stub, emit_stub,
                                                 stop_stub);
    }
    else
    {
      return (RAISEA(stop_stub, 0, (0)));
    }
  }
}

static i64 feed_action(i64 read_stub, i64 emit_stub, i64 stop_stub)
{
  return (
      ((i64(*)(i64, i64, i64, i64))parse)(0, read_stub, emit_stub, stop_stub));
}

static i64 catch_action(i64 stop_stub, i64 emit_stub, i64 n)
{
  i64 i = (i64)(({
    i64 temp = (i64)malloc(1 * sizeof(i64));
    ((i64 *)temp)[0] = (i64)0;
    temp;
  }));
  i64 j = (i64)(({
    i64 temp = (i64)malloc(1 * sizeof(i64));
    ((i64 *)temp)[0] = (i64)0;
    temp;
  }));
  return HANDLE(feed_body, ({TAIL, read}),
                ((i64)(feed_action), i, j, n, stop_stub, emit_stub));
}

static i64 sum_action(i64 emit_stub, i64 n)
{
  return (HANDLE(catch_body, ({ABORT, stop}), ((i64)catch_action, emit_stub, n)));
}

static i64 run(i64 n)
{
  i64 s = (i64)(({
    i64 temp = (i64)malloc(1 * sizeof(i64));
    ((i64 *)temp)[0] = (i64)0;
    temp;
  }));
  i64 _ = (i64)(HANDLE(sum_body, ({TAIL, emit}), ((i64)(sum_action), s, n)));
  return ((i64 *)s)[0];
}

int main(int argc, char *argv[])
{
  init_stack_pool();
  i64 n = (i64)(((i64)(readInt())));
  i64 run_result = (i64)(((i64(*)(i64))run)(n));
  i64 _ = (i64)(((i64)(printInt((int64_t)run_result))));
  destroy_stack_pool();
}
