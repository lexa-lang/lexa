{
  open Parser
}

let white = [' ' '\t']+
let digit = ['0'-'9']
let int = '-'? digit+
let letter = ['a'-'z' 'A'-'Z']
let id_s = ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let id = ['a'-'z' '_'] id_s
let prim = ['~'] id
let sig = ['A'-'Z'] id
(* Constant value start with $ *)
let immediate = '$' '-'? digit+

(* Labels start with _ *)
let label = '_' ['a'-'z' 'A'-'Z' '0'-'9']+

let location = '$' id

(* Comment start with ; *)
let comment = ';' [^'\n']+

(* Single line comment start with # *)
let sl_comment = '#' [^'\n']+

rule read =
  parse
  | white { read lexbuf }
  | '\n' { Lexing.new_line lexbuf; read lexbuf }
  | "<" { LTS }
  | ">" { GTS }
  | "[" { LSB }
  | "]" { RSB }
  | "." { DOT }
  | "," { COMMA }
  | ":=" { COLONEQ }
  | ":" { COLON }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | "let" { LET }
  | "in" { IN }
  | "=" { EQ }
  | "raise" { RAISE }
  | "handle" { HANDLE }
  | "with" { WITH }
  | "newref" { NEWREF }
  | "def" { DEF }
  | "true" { TRUE }
  | "false" { FALSE }
  | "{" { LCB }
  | "}" { RCB }
  | "+" { ADD }
  | "-" { SUB }
  | '*' { MULT }
  | '/' { DIV }
  | "!=" { NEQ }
  | "==" { CMPEQ }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "dcl" { DCL }
  | "effect" { EFFECT }
  | "exc" { EXC }
  | "obj" { OBJ }
  | "." { DOT }
  | "hdl_1" { HDL1 }
  | "hdl_s" { HDLS }
  | "resume" { RESUME }
  | "resume_final" { RESUMEFINAL }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | sig { SIG (Lexing.lexeme lexbuf) }
  | id { VAR (Lexing.lexeme lexbuf) }
  | prim { PRIM (Lexing.lexeme lexbuf) }
  | eof { EOF }
  | _ as c { failwith (Printf.sprintf "unexpected character: %C" c) }
  