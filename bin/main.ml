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

let () = 
  Arg.parse speclist (fun file -> inputFile := file) usageMsg;
  let toplevel = IRParser.Main.parseFile !inputFile in
  let compiledStr = genToplevel toplevel in
  let oc = open_out (!outputFile) in
  Printf.fprintf oc "%s\n" compiledStr;
  ();
