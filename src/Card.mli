
(* Cards *)

type rank = int (* 1 to 13, valet=11, dame=12, roi=13 *)
type suit = Trefle | Pique | Coeur | Carreau
type card = rank * suit

(* From 0..51 to cards and back (the Xpat2 way) *)

type cardnum = int (* 0..51 *)
type suitnum = int (* 0..3 *)

val suit_of_num : suitnum -> suit
val num_of_suit : suit -> suitnum

val of_num : cardnum -> card
val to_num : card -> cardnum
val list_of_num : cardnum list -> card list

val is_king : card -> bool
val compare_card : card -> card -> int

val valid_rank : cardnum -> bool

val string_to_card : string -> card option

(* Display of a card *)

val to_string : card -> string
