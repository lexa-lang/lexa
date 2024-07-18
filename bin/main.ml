open Arg
open Codegen

let usage_msg = "sstal <file1> -o <output> -r "

let input_file = ref ""
let output_file = ref ""

let flag_format = ref false
let flag_no_tail = ref false

let speclist = [
  ("-o", Set_string output_file, "Set the output file name");
  ("--format", Set flag_format, "format the output");
  ("--no-tail", Set flag_no_tail, "disable tail call optimization");
]

let clang_format code =

  let (inp, outp) = Unix.open_process "clang-format" in
  output_string outp code;       (* Send the string to clang-format *)
  close_out outp;                (* Close the input stream *)
  let result = In_channel.input_all inp in
  ignore (Unix.close_process (inp, outp)); (* Close the process and ignore the exit status *)
  result


let () = 
  Arg.parse speclist (fun file -> input_file := file) usage_msg;
  let toplevels_syntax = IRParser.Main.parseFile !input_file in

  let toplevels_closure = Codegen__Closure.closure_convert_toplevels toplevels_syntax in

  let compiledStr = gen_top_level_s toplevels_closure ~tail:(not !flag_no_tail) in
  let compiledStr = if !flag_format then clang_format compiledStr else compiledStr in
  let oc = open_out (!output_file) in
  Printf.fprintf oc "%s\n" compiledStr;
  ();
