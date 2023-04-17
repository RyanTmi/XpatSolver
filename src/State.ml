
(* State *)

open Card
open Game
open PArray

(* ---------------------------------- Types --------------------------------- *)

(* ----- Move type ----- *)

type destination =
  | Column of card
  | Register
  | Empty

type move = card * destination

exception Invalid_move

(* ----- State type ---- *)

type deposit = int * int * int * int
type columns = card list PArray.t
type registers = card list
type history = move list

type state = {
  deposit : deposit;
  columns : columns;
  registers : registers option;
  history : history
}


let compare_state st1 st2 =
  let reg_cmp = compare st1.registers st2.registers in
  if reg_cmp <> 0 then reg_cmp
  else compare st1.columns st2.columns

(* -------------------------------------------------------------------------- *)


(* --------------------------- Display of a state --------------------------- *)

let print_list l f =
  let rec print_elts = function
    | [] -> () | [x] -> f x
    | h::t -> f h; print_string "; "; print_elts t
  in print_string "[ "; print_elts l; print_endline " ]"


let print_card_list cards =
  print_list cards (fun c -> Printf.printf "%4s" (Card.to_string c))


(* Affiche les colonnes avec le sommet de pile à gauche! *)
let print_columns columns =
  print_endline "Columns:";
  let print_format_col i cards =
    Printf.printf "%2d: " (i + 1); print_card_list cards
  in PArray.iteri print_format_col columns


let print_deposit (tr, pi, co, ca) =
  print_endline "Deposit:";
  Printf.printf "(Tr: %d), (Pi: %d), (Co: %d), (Ca: %d)\n" tr pi co ca;
  print_newline ()


let print_registers = function
  | None -> ()
  | Some r -> print_endline "Registers :";
    print_card_list r; print_newline ()


let to_string st =
  print_deposit st.deposit;
  print_registers st.registers;
  print_columns st.columns

(* -------------------------------------------------------------------------- *)


(* -------------------------- Init state functions -------------------------- *)

(* Coupe en deux une liste à partir d'un indice *)
let rec split_at l = function
  | 0 -> [], l
  | n -> if l = [] then [], []
    else let l1, l2 = split_at (List.tl l) (n - 1) in
    List.hd l::l1, l2


(* Rempli les colonnes de cartes selon une permutation,
   ainsi que le reste de la permutation si toutes les
   cartes n'ont pas été placées dans les colonnes *)
let get_initial_columns game perm =
  let nb_cards_to_put = List.init (nb_columns game) (nb_cards game) in
  let fill_columns (columns, perm) nb =
    let column, perm = split_at perm nb in
    (Game.fill_column_rules column game |> List.rev)::columns, perm
  in
    let col, perm = List.fold_left fill_columns ([], perm) nb_cards_to_put in
    PArray.of_list (List.rev col), perm

(* -------------------------------------------------------------------------- *)


(* ------------------------- Card movement functions ------------------------ *)

(* ---------- utils fonctions ----------- *)

(* Retourne l'index de la premiere colonne qui vérifie,
   la fonction 'f', si elle existe et None sinon *)
let first_index_of columns f =
  let len = PArray.length columns in
  let rec index_of_rec i =
    if i = len then raise Invalid_move
    else if PArray.get columns i |> f
    then i else i + 1 |> index_of_rec
  in index_of_rec 0


(* Renvoie true si 'c' est la tête de liste, false sinon. *)
let is_on_top e = function
  | [] -> false
  | h::_ -> h = e


let get_accessible_from_columns st =
  let get_top column l = match column with
    | [] -> l | h::_ -> h::l
  in PArray.fold get_top st.columns []


(* Renvoie la liste des cartes accessible.
   i.e les cartes des registres, cartes en sommet de colonnes. *)
let get_all_accessible_cards st =
  let reg = Option.value st.registers ~default: [] in
  List.rev_append (get_accessible_from_columns st) reg

(* -------------------------------------- *)

(* -------- add/remove functions -------- *)

let add_to_deposit (tr, pi, co, ca) (rk, s) =
  match s with
  | Trefle when tr + 1 = rk -> (rk, pi, co, ca)
  | Pique when pi + 1 = rk -> (tr, rk, co, ca)
  | Coeur when co + 1 = rk -> (tr, pi, rk, ca)
  | Carreau when ca + 1 = rk -> (tr, pi, co, rk)
  | _ -> (tr, pi, co, ca)


let add_to_columns columns card i =
  card::PArray.get columns i |> PArray.set columns i


let add_to_registers registers card =
  card::registers |> List.sort compare_card


let add_to_history st move =
  { st with history = move::st.history }


let remove_from_columns columns i =
  PArray.get columns i |> List.tl |> PArray.set columns i


let remove_from_registers registers card =
  let _, reg = List.partition (fun c -> c = card) registers in
  if reg = registers then raise Invalid_move else reg


let is_registers_full game registers =
  List.length registers >= get_nb_reg game


let remove_card st card =
  let reg = Option.value st.registers ~default: [] in
  if List.mem card reg then
    let new_reg = remove_from_registers reg card in
    { st with registers = Some new_reg}
  else
    let i = first_index_of st.columns (is_on_top card) in
    let new_col = remove_from_columns st.columns i in
    { st with columns = new_col }

(* ------------------------------------- *)

(* ------ checking move functions ------ *)

let is_accessible st card =
  get_all_accessible_cards st |> List.mem card

let valid_column_dest game st c1 c2 =
  column_rules c1 c2 game &&
  is_accessible st c2

let valid_registers_dest game st =
  if st.registers = None then false
  else not (Option.get st.registers |> is_registers_full game)


let valid_empty_col_dest game st cnum =
  if PArray.exists (fun l -> l = []) st.columns then
  empty_col_rules cnum game else false


let is_valid_dest game st c1 = function
  | Column c2 -> valid_column_dest game st c1 c2
  | Register -> valid_registers_dest game st
  | Empty -> valid_empty_col_dest game st c1


let is_valid_move game st (c1, dest) =
  is_accessible st c1 && is_valid_dest game st c1 dest

(* ------------------------------------ *)

(* ---------- move functions ---------- *)

let move_to_registers st card =
  let registers = Option.get st.registers in
  let new_reg = Some (add_to_registers registers card) in
  { st with registers = new_reg }


(* Déplace la carte dans la première colonne vide. *)
let move_to_empty st card =
  let i = first_index_of st.columns (fun l -> l = []) in
  let new_col = add_to_columns st.columns card i in
  { st with columns = new_col }


let move_to_columns c2 st c1 =
  let i = first_index_of st.columns (is_on_top c2) in
  let new_col = add_to_columns st.columns c1 i in
  { st with columns = new_col }


(* Renvoie une fonction de déplacement selon le type de destination. *)
let move_to = function
  | Column c2 -> c2 |> move_to_columns
  | Register -> move_to_registers
  | Empty -> move_to_empty


(* Effectue le déplacement d'une carte,
   en supposant que le mouvement est valide *)
let move_card st (c1, dest) =
  move_to dest (remove_card st c1) c1

(* ------------------------------------ *)

(* ----------- normalization ---------- *)

(* Rajoute toutes les cartes accessibles au dépôt
   si cela est possible et retire la carte
   des registres ou des colonnes dans ce cas. *)
let rec normalization st = function
  | [] -> st
  | card::t ->
    let new_dep = add_to_deposit st.deposit card in
    if new_dep = st.deposit then normalization st t
    else
      let new_st = remove_card st card in
      { new_st with deposit = new_dep }


let rec normalize_state st =
  let cards = get_all_accessible_cards st in
  let new_state = normalization st cards in
  if new_state = st then new_state
  else normalize_state new_state

(* ------------------------------------ *)

(* -------------------------------------------------------------------------- *)


(* ----------------------------- Get neighbors ------------------------------ *)

let get_col_moves src dst =
  let create_moves card cards =
    List.map (fun c -> card, Column c) cards
  in List.fold_right (fun c m -> List.rev_append (create_moves c dst) m) src []

let get_empty_col_moves st cards =
  if PArray.exists (fun l -> l = []) st.columns then
    List.map (fun c -> c, Empty) cards else []

let get_reg_moves st cards =
  if st.registers = None then []
  else List.map (fun c -> c, Register) cards

let get_all_moves game st =
  let col_cards = get_accessible_from_columns st in
  let reg_cards = Option.value st.registers ~default:[] in
  let all_cards = List.rev_append reg_cards col_cards in
    get_col_moves all_cards col_cards |>
    List.rev_append (get_empty_col_moves st all_cards) |>
    List.rev_append (get_reg_moves st col_cards)

let get_all_valid_move game st =
  let valid move v_moves =
    if is_valid_move game st move then move::v_moves else v_moves
  in List.fold_right valid (get_all_moves game st) []

(* -------------------------------------------------------------------------- *)


(* ----------------------------- Main functions ----------------------------- *)

let score st =
  let tr, pi, co, ca = st.deposit in tr + pi + co + ca


let is_goal st = score st = 52


let get_initial_state game perm =
  let columns, perm = get_initial_columns game (list_of_num perm) in
  { deposit = (0, 0, 0, 0); columns = columns;
    registers = registers_rules perm game; history = [] } |> normalize_state


let process_move game st move =
  if is_valid_move game st move then
    add_to_history (move_card st move) move |> normalize_state
  else raise Invalid_move


let get_nb_cards_can_be_moved game st =
  get_all_valid_move game st |> List.length


let get_accessible_states game st =
  get_all_valid_move game st |> List.map (fun m -> process_move game st m)

(* -------------------------------------------------------------------------- *)
