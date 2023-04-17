
(* CheckGame *)

open State
open IOSystem


type check =
  | Success
  | Failure of int


(* Reproduit les coups en fonction de l'état courant
  de la partie, et selon les règles du jeu. *)
let rec process_check game state nb_coup = function
  | [] ->
    if is_goal state then Success
    else let fail = Failure nb_coup in State.to_string state; fail
  | move::t ->
    try
      let new_state = process_move game state move in
      process_check game new_state (nb_coup + 1) t
    with Invalid_move -> State.to_string state; Failure nb_coup


let check_game game init_st file_name =
  let moves = file_to_moves file_name in
  match process_check game init_st 1 moves with
  | Success ->
    print_endline ("File " ^ file_name ^ " is a valid solution\n");
    print_endline "SUCCES"; exit 0
  | Failure n -> Printf.printf "\nECHEC %d" n; print_newline (); exit n
