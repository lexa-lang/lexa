open Arg
open Codegen

let usageMsg = "sstal <file1> -o <output> -r "

let inputFile = ref ""
let outputFile = ref ""

let flagRun = ref false

let speclist = [
  ("-o", Set_string outputFile, "Set the output file name");
  ("-r", Set flagRun, "run the file");
]

let clang_format code =

  let (inp, outp) = Unix.open_process "clang-format" in
  output_string outp code;       (* Send the string to clang-format *)
  close_out outp;                (* Close the input stream *)
  let result = In_channel.input_all inp in
  ignore (Unix.close_process (inp, outp)); (* Close the process and ignore the exit status *)
  result


let () = 
  Arg.parse speclist (fun file -> inputFile := file) usageMsg;
  let toplevels_syntax = IRParser.Main.parseFile !inputFile in

  let toplevels_closure = Codegen__Closure.closure_convert_toplevels toplevels_syntax in

  let compiledStr = gen_top_level_s toplevels_closure in
  let formatedStr = clang_format compiledStr in
  let oc = open_out (!outputFile) in
  Printf.fprintf oc "%s\n" formatedStr;
  ();
