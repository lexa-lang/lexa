open Syntax

type location =
  | Location of Lexing.position * Lexing.position (** delimited location *)
  | Nowhere (** no location *)

exception Error of (location * string * string)

let print_location loc ppf =
  match loc with
  | Nowhere ->
      Format.fprintf ppf "unknown location"
  | Location (begin_pos, end_pos) ->
      let begin_char = begin_pos.Lexing.pos_cnum - begin_pos.Lexing.pos_bol in
      let end_char = end_pos.Lexing.pos_cnum - begin_pos.Lexing.pos_bol in
      let begin_line = begin_pos.Lexing.pos_lnum in
      let filename = begin_pos.Lexing.pos_fname in

      if String.length filename != 0 then
        Format.fprintf ppf "file %S, line %d, charaters %d-%d" filename begin_line begin_char end_char
      else
        Format.fprintf ppf "line %d, characters %d-%d" (begin_line - 1) begin_char end_char

let print_message ?(loc=Nowhere) msg_type =
  match loc with
  | Location _ ->
     Format.eprintf "%s at %t:@\n" msg_type (print_location loc) ;
     Format.kfprintf (fun ppf -> Format.fprintf ppf "@.") Format.err_formatter
  | Nowhere ->
     Format.eprintf "%s: " msg_type ;
     Format.kfprintf (fun ppf -> Format.fprintf ppf "@.") Format.err_formatter

let print_error (loc, err_type, msg) = print_message ~loc err_type "%s" msg

let error ?(kind="Error") ?(loc=Nowhere) =
  let k _ =
    let msg = Format.flush_str_formatter () in
      print_error (loc, kind, msg);
      raise (Error (loc, kind, msg))
  in
    Format.kfprintf k Format.str_formatter

let location_of_lex lex =
  Location (Lexing.lexeme_start_p lex, Lexing.lexeme_end_p lex)

let syntax_error ?loc msg = 
  error ~kind:"Syntax error" ?loc msg

let fatal_error msg = error ~kind:"Fatal error" msg

let wrap_syntax_errors parser lex =
  try
    parser lex
  with
    | Failure _ ->
      syntax_error ~loc:(location_of_lex lex) "unrecognised symbol"
    | _ ->
      syntax_error ~loc:(location_of_lex lex) "syntax error"

let parse (s : string) : toplevel =
  let lexbuf = Lexing.from_string s in
  let defs = Parser.prog Lexer.read lexbuf in
  defs

let read_file parser fn =
  try
    let fh = open_in fn in
    let lex = Lexing.from_channel fh in (* Create a lexbuf *)
    lex.Lexing.lex_curr_p <- {lex.Lexing.lex_curr_p with Lexing.pos_fname = fn};
    try
      let terms = parser lex in
      close_in fh;
      terms
    with
      (* Close the file in case of any parsing errors. *)
      | Error err -> close_in fh ; print_error err; exit 1;
      | Sys_error x -> Printf.printf "%s" x; exit 1;
  with
    (* Any errors when opening or closing a file are fatal. *)
    Sys_error msg -> fatal_error "%s" msg
    
let parseFile inputFilename =
  read_file (wrap_syntax_errors (Parser.prog Lexer.read)) inputFilename