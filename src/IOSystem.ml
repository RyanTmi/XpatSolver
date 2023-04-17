
(* IOSystem *)

open State
open Card

(* ------------- Read ------------- *)

(* Exception levée lorsque le fichier est mal formaté. *)
exception Wrong_file_format

let get_dest dst =
  match string_to_card dst with
  | Some card -> Some (Column card)
  | _ -> match dst with
    | "V" -> Some Empty
    | "T" -> Some Register
    | _ -> None


let line_to_move (str1, str2) =
  match string_to_card str1, get_dest str2 with
  | Some src, Some dst -> src, dst
  | _ -> raise Wrong_file_format


let read_line ic =
  let line = Stdlib.input_line ic in
  match String.split_on_char ' ' line with
    | [str1; str2] -> str1, str2
    | _ -> raise Wrong_file_format


let rec get_moves ic moves =
  try
    let move = read_line ic in
    move::moves |> get_moves ic
  with
  | End_of_file -> close_in ic; moves
  | _ -> close_in ic; raise Wrong_file_format


let file_to_moves file_name =
  let ic = Stdlib.open_in file_name in
  let moves = get_moves ic [] in
  List.rev_map line_to_move moves

(* -------------------------------- *)

(* ------------- Write ------------ *)

let solution_directory = "solution_file"

let dest_to_string = function
  | Column c -> to_num c |> Printf.sprintf "%d"
  | Register -> "T"
  | Empty -> "V"

let move_to_line (c, dest) =
  dest_to_string dest |> Printf.sprintf "%d %s\n" (to_num c)


let rec write_lines oc = function
  | [] -> close_out oc
  | line::t -> output_string oc line; write_lines oc t


let moves_to_file file_name moves =
  let lines = List.rev_map move_to_line moves in
  if file_name = "out.sol" then
    let oc = open_out file_name in
    write_lines oc lines;
  else
    try Unix.mkdir solution_directory 0o744; with _ -> ();
    let oc = open_out (solution_directory ^ "/" ^ file_name) in
    write_lines oc lines;

(* -------------------------------- *)