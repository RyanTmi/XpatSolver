
(* Cards *)

type rank = int (* 1 to 13, valet=11, dame=12, roi=13 *)
type suit = Trefle | Pique | Coeur | Carreau
type card = rank * suit

(* From 0..51 to cards and back (the Xpat2 way) *)
type cardnum = int (* 0..51 *)

type suitnum = int (* 0..3 *)


let num_of_suit = function
  | Trefle -> 0
  | Pique -> 1
  | Coeur -> 2
  | Carreau -> 3

let suit_of_num = function
  | 0 -> Trefle
  | 1 -> Pique
  | 2 -> Coeur
  | 3 -> Carreau
  | _ -> assert false


let of_num n = (n lsr 2) + 1, suit_of_num (n land 3)
let to_num (rk, s) = num_of_suit s + (rk - 1) lsl 2

let is_king (rk, _) = rk = 13
let list_of_num l = List.map (fun i -> of_num i) l
let compare_card c1 c2 = if to_num c1 > to_num c2 then 1 else -1
let valid_rank cnum = cnum >= 0 && cnum < 52

let string_to_card str =
  match int_of_string_opt str with
  | Some cnum when valid_rank cnum -> Some (of_num cnum)
  | _ -> None


(* ------- Display of a card ------- *)

let suit_to_string = function
  | Trefle -> "Tr"
  | Pique -> "Pi"
  | Coeur -> "Co"
  | Carreau -> "Ca"

let rank_to_string = function
  | 13 -> "Ro"
  | 12 -> "Da"
  | 11 -> "Va"
  | n -> string_of_int n

let to_string (rk, s) = rank_to_string rk ^ suit_to_string s
