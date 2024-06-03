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
%token PERC
%token VALDEF
%token SEMICOLON
%token FUN

%start <Syntax.top_level list> prog
%nonassoc SEMICOLON
%nonassoc ELSE
%nonassoc NEQ CMPEQ LTS GTS
%nonassoc COLONEQ
%left ADD SUB
%left MULT DIV PERC
%nonassoc LSB
%%

prog:
  | list(top_level); EOF { $1 }

top_level:
  | DEF name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN 
      LCB e = expr RCB { TLAbs (name, params, e) }
  | EFFECT name = SIG LCB l = list(effect_sig) RCB { TLEffSig (name, l) }
  | OBJ name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN 
      LCB l = list(hdl_def) RCB { TLObj (name, params, l) }
      
// arith:
//   | ADD { AAdd }
//   | SUB { ASub }
//   | MULT { AMult }
//   | DIV { ADiv }
//   | PERC { AMod }
  
// cmp:
//   | CMPEQ { CEq }
//   | NEQ { CNeq }
//   | GTS { CGt }
//   | LTS { CLt }

effect_sig:
  | DCL v = VAR { v }

hdl_anno:
  | DEF { HDef }
  | EXC { HExc }
  | HDL1 { HHdl1 }
  | HDLS { HHdls }

hdl_def:
  | a = hdl_anno name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN LCB e = expr RCB { (a, name, params, e) }

heap_value:
  | LCB l = separated_list(COMMA, simple_expr) RCB { l }

app_expr:
  | simple_expr { $1 }
  | e1 = app_expr LPAREN args = separated_list(COMMA, expr) RPAREN { App (e1, args) }

expr:
  | app_expr { $1 }
  | e1 = expr ADD e2 = expr { Arith(e1, AAdd, e2) }
	| e1 = expr SUB e2 = expr { Arith(e1, ASub, e2) }
	| e1 = expr MULT e2 = expr { Arith(e1, AMult, e2) }
	| e1 = expr DIV e2 = expr { Arith(e1, ADiv, e2) }
	| e1 = expr PERC e2 = expr { Arith(e1, AMod, e2) }
	
	| e1 = expr CMPEQ e2 = expr { Cmp(e1, CEq, e2) }
	| e1 = expr NEQ e2 = expr { Cmp(e1, CNeq, e2) }
	| e1 = expr GTS e2 = expr { Cmp(e1, CGt, e2) }
	| e1 = expr LTS e2 = expr { Cmp(e1, CLt, e2) }
	
  | NEWREF heap_value { New $2 }
  | v = expr LSB v2 = expr RSB { Get (v, v2) }
  | v1 = expr LSB v2 = expr RSB COLONEQ v3 = expr { Set (v1, v2, v3) }
  | VALDEF x = VAR EQ t1 = expr SEMICOLON t2 = expr { Let (x, t1, t2) }
  | IF v = expr THEN t1 = expr ELSE t2 = expr { If (v, t1, t2) }
  | RAISE stub = VAR DOT hdl = VAR params = list(simple_expr) { Raise (stub, hdl, params) }
  | RESUME k = VAR v = simple_expr { Resume (k, v) }
  | RESUMEFINAL k = VAR v = simple_expr { ResumeFinal (k, v) }
  | HANDLE LCB env = separated_list(COMMA, VAR) RCB body = VAR WITH obj = VAR COLON sig_name = SIG { Hdl (env, body, obj, sig_name) }
  | VALDEF x = VAR EQ FUN LPAREN params = separated_list(COMMA, VAR) RPAREN LCB body = expr RCB SEMICOLON e2 = expr { Letrec (x, params, body, e2) }

simple_expr:
  | VAR { Var $1 }
  | INT { Int $1 }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | PRIM { Prim $1 }
  | LPAREN e = expr RPAREN { e }    