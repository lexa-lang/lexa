{
  open Parser
}

let white = [' ' '\t']+
let digit = ['0'-'9']
let int = '-'? digit+
let letter = ['a'-'z' 'A'-'Z']
let id = ['a'-'z' '0'-'9' '_' '-']+
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
  | "throw" { THROW }
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
  | '>' { GT }
  | '<' { LT }
  | "==" { CMPEQ }
  | "if" { IF }
  | "then" { THEN }
  | "else" { ELSE }
  | "dcl" { DCL }
  | "effect" { EFFECT }
  | "exc" { EXC }
  | "hdl" { HDL }
  | "obj" { OBJ }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | sig { SIG (Lexing.lexeme lexbuf) }
  | id { VAR (Lexing.lexeme lexbuf) }
  | eof { EOF }
  | _ as c { failwith (Printf.sprintf "unexpected character: %C" c) }
  