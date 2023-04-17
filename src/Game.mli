
(* Game *)

type game = Freecell | Seahaven | Midnight | Baker

val of_string : string -> game
val to_string : game -> string

(* val c_game : game ref *)


(* -------------------------- Game rules functions -------------------------- *)

(* Nombre de colonnes pour un jeu donné *)
val nb_columns : game -> int

(* Nombre de cartes à mettre dans une colonne *)
val nb_cards : game -> int -> int

(* Nombre de registres selon le type de jeu *)
val get_nb_reg : game -> int

open Card

(**
  Les fonctions suivantes aident lors d'un changement
  qui dépend du type de jeu comme:
    - Une colonne vide ne peut recevoir qu'un Roi. (Seahaven)
    - Les rois sont descendus au fond de leurs colonnes (Baker)
*)

(* Règle pour le remplissage des colonnes. *)
val fill_column_rules : card list -> game -> card list

(* Règle pour le remplissage des registres. *)
val registers_rules : card list -> game -> card list option

(* Règle de déplacement vers une colonne. *)
val column_rules : card -> card -> game -> bool

(* Règle de déplacement vers une colonne vide. *)
val empty_col_rules : card -> game -> bool

(* -------------------------------------------------------------------------- *)
