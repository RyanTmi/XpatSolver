
(* Game *)

type game = Freecell | Seahaven | Midnight | Baker


let of_string = function
  | "FreeCell"|"fc" -> Freecell
  | "Seahaven"|"st" -> Seahaven
  | "MidnightOil"|"mo" -> Midnight
  | "BakersDozen"|"bd" -> Baker
  | _ -> raise Not_found

let to_string = function
  | Freecell -> "Freecell"
  | Seahaven -> "Seahaven"
  | Midnight -> "Midnight"
  | Baker -> "Baker"


let nb_columns = function
  | Freecell -> 8
  | Seahaven -> 10
  | Midnight -> 18
  | Baker -> 13

let nb_cards game i =
  match game with
  | Freecell -> 7 - i mod 2
  | Seahaven -> 5
  | Midnight -> 3
  | Baker -> 4

let get_nb_reg = function
  | Freecell | Seahaven -> 4
  | _ -> 0

open Card

let fill_column_rules column = function
  | Baker -> let l, r = List.partition is_king column in l @ r
  | _ -> column


let registers_rules cards = function
  | Freecell when List.length cards = 0 -> Some []
  | Seahaven -> Some (List.sort compare_card cards)
  | Midnight | Baker when List.length cards = 0 -> None
  | _ -> failwith "Invalid filling of columns"


let column_rules (r1, s1) (r2, s2) game =
  let valid_rank = r1 + 1 = r2 in
  let valid_color = function
    | Freecell -> num_of_suit s1 / 2 <> num_of_suit s2 / 2
    | Seahaven | Midnight -> num_of_suit s1 = num_of_suit s2
    | Baker -> true
  in valid_rank && valid_color game


let empty_col_rules card = function
  | Freecell -> true
  | Seahaven -> is_king card
  | _ -> false
