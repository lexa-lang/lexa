%{
  open Syntax
  open Syntax__Common
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
%token RESUME
%token RESUMEFINAL
%token PERC
%token VALDEF
%token SEMICOLON
%token FUN
%token REC
%token AND

%start <Syntax.top_level list> prog

%nonassoc STMT
%nonassoc HIGHER_THAN_STMT
%left SEMICOLON
%nonassoc ELSE
%nonassoc NEQ CMPEQ LTS GTS
%nonassoc COLONEQ
%left ADD SUB
%left MULT DIV PERC
%%

// There is probably more undiscovered bugs in the parsing rules

prog:
  | list(top_level); EOF { $1 }

top_level:
  | DEF name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN 
      LCB e = expr RCB { TLAbs (name, params, e) }
  | EFFECT name = SIG LCB l = list(effect_sig) RCB { TLEffSig (name, l) }
      
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
  | LCB l = separated_list(COMMA, expr) RCB { l }

recfun:
  | name = VAR LPAREN params = separated_list(COMMA, VAR) RPAREN LCB e = expr RCB 
    { ({name = name; params = params; body = e} : Syntax.fundef) }

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
  | v1 = simple_expr LSB v2 = expr RSB COLONEQ v3 = expr { Set (v1, v2, v3) }
  | VALDEF x = VAR EQ t1 = expr SEMICOLON t2 = expr %prec HIGHER_THAN_STMT { Let (x, t1, t2) }
  | IF v = expr THEN t1 = expr ELSE t2 = expr { If (v, t1, t2) }
  | RAISE stub = simple_expr DOT hdl = VAR params = list(simple_expr) { Raise (stub, hdl, params) }
  | RESUME k = simple_expr v = simple_expr { Resume (k, v) }
  | RESUMEFINAL k = simple_expr v = simple_expr { ResumeFinal (k, v) }
  | HANDLE LCB handle_body = expr RCB WITH stub = VAR COLON sig_name = SIG LCB handler_defs = list(hdl_def) RCB 
    { Handle {handle_body; stub; sig_name; handler_defs} }
  | FUN LPAREN params = separated_list(COMMA, VAR) RPAREN LCB body = expr RCB { Fun (params, body) }
  | REC DEF fs = separated_list(AND, recfun) SEMICOLON e = expr { Recdef (fs, e) }
  | e1 = expr SEMICOLON e2 = expr %prec STMT { Stmt (e1, e2) }
  // | VALDEF x = VAR EQ FUN LPAREN params = separated_list(COMMA, VAR) RPAREN LCB body = expr RCB SEMICOLON e2 = expr { Recdef (x, params, body, e2) }

simple_expr:
  | VAR { Var $1 }
  | INT { Int $1 }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | PRIM { Prim $1 }
  | LPAREN e = expr RPAREN { e }
  | v = simple_expr LSB v2 = expr RSB { Get (v, v2) }    