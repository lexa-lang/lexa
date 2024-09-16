open Arg
open Codegen

module StringSet = Syntax__Varset

let usage_msg = "lexa <file1> -o <output> -r "

let input_file = ref ""
let output_file = ref ""

let flag_no_format = ref false
let flag_no_tail = ref false

let speclist = [
  ("-o", Set_string output_file, "Set the output file name");
  ("--no-format", Set flag_no_format, "do not format the output");
  ("--no-tail", Set flag_no_tail, "disable tail call optimization");
]

let clang_format code =
  let temp_file, oc = Filename.open_temp_file "temp" ".c" in
  output_string oc code;
  close_out oc;

  let _ = Unix.system ("clang-format -i " ^ temp_file) in

  let ic = open_in temp_file in
  let result = really_input_string ic (in_channel_length ic) in
  close_in ic;

  Sys.remove temp_file;
  result

let rec get_open_filenames filename =
  let toplevels = IRParser.Main.parseFile filename in
  (* Get the list of filenames opened from a toplevel list *)
  let get_cur_open_filenames = function
    | Syntax.TLOpen x -> Some ((Filename.dirname filename) ^ "/" ^ x)
    | _ -> None
  in
  let cur_opens = List.filter_map get_cur_open_filenames toplevels in
  
  let all_open_filenames = List.concat_map get_open_filenames cur_opens in
  all_open_filenames @ [filename]

let rec dedup l acc =
  match l with
  | h :: t ->
    if List.mem h acc then
      dedup t acc
    else
      h :: (dedup t (h :: acc))
  | [] -> []

let compile_file filename =
  let open_filenames = dedup (get_open_filenames filename) [] in
  let all_toplevels = List.concat_map
    (fun fn -> IRParser.Main.parseFile fn)
    open_filenames
  in
  
  let toplevels_closure = Codegen__Closure.closure_convert_toplevels all_toplevels in
  let compiled_str = gen_top_level_s toplevels_closure ~tail:(not !flag_no_tail) in
  let compiled_str = if !flag_no_format then compiled_str else clang_format compiled_str in
  
  compiled_str
  
let () = 
  Arg.parse speclist (fun file -> input_file := file) usage_msg;  
  let compiled_str = compile_file !input_file in
  let oc = open_out (!output_file) in
  Printf.fprintf oc "%s\n" compiled_str;
  ();
