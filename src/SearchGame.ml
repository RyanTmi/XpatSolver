
open State
open Game
open IOSystem


module States = Set.Make (struct type t = state let compare = compare_state end)

type node = { state : state; g_cost : int; h_cost : int }

let f_cost node = node.g_cost + node.h_cost

let compare_node node1 node2 =
  if compare_state node1.state node2.state = 0 then 0
  else if compare (f_cost node1) (f_cost node2) > 0 then 1 else -1

module Nodes = Set.Make (struct type t = node let compare = compare_node end)

type search = Sucess of state | Fail

(* ------------------------------- Heuristics ------------------------------- *)

(* Coefficients qui fonctionnent pas mal selon nos tests *)
let c_score = function
  | Baker | Seahaven -> 1
  | Freecell -> 4
  | Midnight -> 5

let c_columns = function
  | Baker | Seahaven  -> 1
  | Freecell -> 3
  | Midnight -> 2

let c_cards = function
  | Baker | Seahaven -> 1
  | Freecell -> 2
  | Midnight -> 3


let h_score st = 52 - score st

let h_columns game st =
  let count_empty_col col i = if col = [] then i + 1 else i in
  nb_columns game - PArray.fold count_empty_col st.columns 0

let h_cards = get_nb_cards_can_be_moved

let h game st =
  h_score st * c_score game +
  h_columns game st * c_columns game +
  h_cards game st * c_cards game

let get_neighbors game node =
  let to_node st =
    { state = st; g_cost = node.g_cost + 1; h_cost = h game st }
  in get_accessible_states game node.state |> List.map to_node

(* -------------------------------------------------------------------------- *)

let a_star game st =
  let rec v_neighbors o_set c_set = function
    | [] -> o_set
    | node::tl ->
      if States.mem node.state c_set then v_neighbors o_set c_set tl
      else
        if Nodes.mem node o_set then v_neighbors o_set c_set tl
        else v_neighbors (Nodes.add node o_set) c_set tl
  in
  let rec visite o_set c_set =
    if Nodes.is_empty o_set then Fail
    else
      let cur_node = Nodes.min_elt o_set in
      let o_set = Nodes.remove cur_node o_set in
      if is_goal cur_node.state then Sucess cur_node.state
      else
        let c_set = States.add cur_node.state c_set in
        let neighbors = get_neighbors game cur_node in
        let o_set = v_neighbors o_set c_set neighbors in
        visite o_set c_set
  in
    let start_node = { state = st; g_cost = 0; h_cost = h game st } in
    visite (Nodes.singleton start_node) States.empty


let search_game game init_st file_name =
  match a_star game init_st with
  | Sucess st ->
    moves_to_file file_name st.history;
    let file_name = (
      if file_name = "out.sol" then file_name
      else solution_directory ^ "/" ^ file_name
    ) in
    print_endline ("Solution written in " ^ file_name);
    print_newline ();
    print_endline "SUCCES"; exit 0
  | Fail -> print_endline "INSOLUBLE"; exit 2
