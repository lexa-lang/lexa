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
let prim = ['~'] id_s
let sig = ['A'-'Z'] id?
let capitalized_var = ['A' - 'Z'] id_s

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
  
  | "|" { VBAR }
  | "type" { TYPE }
  | "of" { OF }
  | "match" { MATCH }
  | "->" { RARROW }
  | "open" { OPEN }
  | '"' { read_string (Buffer.create 17) lexbuf }
  | '\'' { read_char (Buffer.create 17) lexbuf }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | int { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | id { VAR (Lexing.lexeme lexbuf) }
  | prim { PRIM (Lexing.lexeme lexbuf) }
  | capitalized_var { CAPITALIZED_VAR (Lexing.lexeme lexbuf) }
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
  
and read_char buf =
  parse
  | '\\' '\\' '\'' { CHAR '\\' }
  | '\\' 'b' '\'' { CHAR '\b' }
  | '\\' 'f' '\'' { CHAR '\012' }
  | '\\' 'n' '\'' { CHAR '\n' }
  | '\\' 'r' '\'' { CHAR '\r' }
  | '\\' 't' '\'' { CHAR '\t' }
  | '\\' '\'' '\'' { CHAR '\'' }
  | [^ '"' '\\'] '\''
    { Buffer.add_char buf (Lexing.lexeme_char lexbuf 0);
      CHAR (Buffer.nth buf 0)
    }
  | _ { raise (SyntaxError ("Illegal char character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("Char is not terminated")) }

and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_string buf "/"; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_string buf "\\\\"; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_string buf "\\b"; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_string buf "\\012"; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_string buf "\\n"; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_string buf "\\r"; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_string buf "\\t"; read_string buf lexbuf }
  | '\\' '"'  { Buffer.add_string buf "\\\""; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("String is not terminated")) }