{
  open Parser
  open Lexing
  exception SyntaxError of string
}

let white = [' ' '\t']+
let digit = ['0'-'9']
let int = '-'? digit+
let float = '-'? digit+ '.' digit+
let letter = ['a'-'z' 'A'-'Z']
let id_s = ['a'-'z' 'A'-'Z' '0'-'9' '_' '-']*
let id = ['a'-'z' '_'] id_s
let prim = ['~'] id
let sig = ['A'-'Z'] id?

rule read =
  parse
  | "//" { read_single_line_comment lexbuf }
  | "/*" { read_multi_line_comment lexbuf }
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
  | "." { DOT }
  | "hdl_1" { HDL1 }
  | "hdl_s" { HDLS }
  | "resume" { RESUME }
  | "resume_final" { RESUMEFINAL }
  | "%" { PERC }
  | "val" { VALDEF }
  | ";" { SEMICOLON }
  | "fun" { FUN }
  | "rec" { REC }
  | "and" { AND }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | sig { SIG (Lexing.lexeme lexbuf) }
  | id { VAR (Lexing.lexeme lexbuf) }
  | prim { PRIM (Lexing.lexeme lexbuf) }
  | eof { EOF }
  | _ as c { failwith (Printf.sprintf "unexpected character: %C" c) }
  
and read_single_line_comment = parse
  | "\n" { new_line lexbuf; read lexbuf }
  | eof { EOF }
  | _ { read_single_line_comment lexbuf }

and read_multi_line_comment = parse
  | "*/" { read lexbuf }
  | "\n" { new_line lexbuf; read_multi_line_comment lexbuf }
  | eof { raise (SyntaxError ("Lexer - Unexpected EOF - please terminate your comment.")) }
  | _ { read_multi_line_comment lexbuf }