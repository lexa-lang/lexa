%{
  open Syntax
  open Stdlib
%}
// %token NEWLINE

%token EOF

%token <int> INT
%token <string> LABEL
%token <string> VAR

%token DOT
%token LPAREN
%token RPAREN
%token COMMA
%token LTS (* less than sign *)
%token GTS
%token EQ
%token LET
%token IN
%token COLONEQ
%token RAISE
%token ABORT
%token THROW
%token HANDLE
%token ARROW
%token LSB
%token RSB
%token WITH
%token NEWREF
%token DEF
%token TRUE
%token FALSE
%token LCB
%token RCB
%token ADD
%token SUB
%token MULT
%token DIV
%token NEQ
%token CMPEQ
%token GT
%token LT
%token IF
%token THEN
%token ELSE

%start <Syntax.value list> prog
%%

prog:
  | list(value); EOF { $1 }

arith:
  | ADD { AAdd }
  | SUB { ASub }
  | MULT { AMult }
  | DIV { ADiv }

cmp:
  | CMPEQ { CEq }
  | NEQ { CNeq }
  | GT { CGt }
  | LT { CLt }

value:
  | VAR { VVar $1 }
  | INT { VInt $1 }
  | DEF name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN LCB t = term RCB { VAbs (name, params, t) }
  | TRUE { VBool true }
  | FALSE { VBool false }

heap_value:
  | LTS l = separated_list(COMMA, value) GTS { l }

term:
  | value { TValue $1 }
  | v1 = value op = arith v2 = value { TArith (v1, op, v2) }
  | v1 = value cmp = cmp v2 = value { TCmp (v1, cmp, v2) }
  | LET VAR EQ t1 = term IN t2 = term { TLet ($2, t1, t2) }
  | value LPAREN vs = separated_list(COMMA, value) RPAREN { TApp ($1, vs) }
  | IF v = value THEN t1 = term ELSE t2 = term { TIf (v, t1, t2) }
  | NEWREF heap_value { TNew $2 }
  | v = value LSB i = INT RSB { TGet (v, i) }
  | v1 = value LSB i = INT RSB COLONEQ v2 = value { TSet (v1, i, v2) }
  | RAISE v1 = value v2 = value { TRaise (v1, v2) }
  | ABORT v1 = value v2 = value { TAbort (v1, v2) }
  | THROW v1 = value v2 = value { TThrow (v1, v2) }
  // | HANDLE LTS l = list(value) GTS LPAREN LAMBDA env = VAR DOT LAMBDA hdl = VAR DOT t = term RPAREN WITH h = handler { THdl (l, (Var env), (Var hdl), t, h) }

// handler:
//   | LAMBDA env = VAR DOT LAMBDA x = VAR DOT LAMBDA k = VAR DOT t = term { HNormal (env, x, k, t) }
//   | LAMBDA env = VAR DOT LAMBDA x = VAR DOT t = term { HAbortive (env, x, t) }

