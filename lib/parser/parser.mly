%{
  open Syntax
  open Stdlib
%}
// %token NEWLINE

%token EOF

%token <int> INT
%token <string> VAR
%token <string> SIG
%token <string> PRIM 

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
%token COLON
%token RAISE
%token HANDLE
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
%token DCL
%token EFFECT
%token EXC
%token HDL1
%token HDLS
%token OBJ
%token RESUME
%token RESUMEFINAL

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
  | LTS { CLt }

effect_sig:
  | DCL v = VAR { v }

hdl_anno:
  | DEF { HDef }
  | EXC { HExc }
  | HDL1 { HHdl1 }
  | HDLS { HHdls }

hdl_def:
  | a = hdl_anno name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN LCB t = term RCB { (a, name, params, t) }

value:
  | VAR { VVar $1 }
  | INT { VInt $1 }
  | DEF name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN LCB t = term RCB { VAbs (name, params, t) }
  | TRUE { VBool true }
  | FALSE { VBool false }
  | EFFECT name = SIG LCB l = list(effect_sig) RCB { VEffSig (name, l) }
  | OBJ name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN LCB l = list(hdl_def) RCB { VObj (name, params, l) }
  | PRIM { VPrim $1 }

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
  | v = value LSB v2 = value RSB { TGet (v, v2) }
  | v1 = value LSB i = INT RSB COLONEQ v2 = value { TSet (v1, i, v2) }
  | RAISE stub = VAR DOT hdl = VAR params = separated_list(COMMA, value) { TRaise (stub, hdl, params) }
  // | ABORT v1 = value v2 = value { TAbort (v1, v2) }
  | RESUME k = VAR v = value { TResume (k, v) }
  | RESUMEFINAL k = VAR v = value { TResumeFinal (k, v) }
  | HANDLE LTS env = separated_list(COMMA, VAR) GTS body = VAR WITH obj = VAR COLON sig_name = SIG { THdl (env, body, obj, sig_name) }

// handler:
//   | LAMBDA env = VAR DOT LAMBDA x = VAR DOT LAMBDA k = VAR DOT t = term { HNormal (env, x, k, t) }
//   | LAMBDA env = VAR DOT LAMBDA x = VAR DOT t = term { HAbortive (env, x, t) }

