
(* State *)

open Card

type destination =
  | Column of card      (* Numéro d'une carte en sommet de colonne *)
  | Register            (* Registre temporaire inocupé *)
  | Empty               (* Première colonne vide disponible *)

type move = card * destination

(* Exception levée lors d'un déplacement illégal. *)
exception Invalid_move

(* -------------- State -------------- *)

open Game

(* Le dépôt est représenté par un 4-uplet d'entier, ils
   correspondent au nombre de cartes déjà posé pour chacune des 4 couleurs. *)
type deposit = int * int * int * int

(* Les colonnes sont représentées par un tableau de type PArray,
   chaque élément du tableau est une liste de cartes. *)
type columns = card list PArray.t

(* Les registres temporaires sont représentés par une liste triée de cartes. *)
type registers = card list

(* Historique des coups menant jusqu'à cette état.
   liste de 'move' renversée. *)
type history = move list


type state = {
  deposit : deposit;
  columns : columns;
  registers : registers option;
  history : history
}

(* ----------------------------------- *)

(* ------------ Functions ------------ *)

(* On comparera leurs registres et s'ils sont égaux
   alors on comparera leurs colonnes c'est tout.*)
val compare_state : state -> state -> int

val to_string : state -> unit

(* Retourne le score de l'état. *)
val score : state -> int

(* Vérifie si 'state' est un état gagnant. *)
val is_goal : state -> bool

(* Retourne l'état initial normalisé d'un jeu
   selon une permutation de cartes. *)
val get_initial_state : game -> int list -> state

(* Effectue un coup et renvoie le nouvel état
   normalisé après ce coup, s'il est valide. *)
val process_move : game -> state -> move -> state

(* Donne le nombre de cartes qui peuvent être déplacées.
   Utile pour une heuristique de recherche de solution. *)
val get_nb_cards_can_be_moved : game -> state -> int

(* Retourne la liste des voisins d'un état,
   i.e l'ensemble des états accessibles. *)
val get_accessible_states : game -> state -> state list

(* ----------------------------------- *)