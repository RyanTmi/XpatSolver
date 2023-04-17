
(* CheckGame *)

type check =
  | Success
  | Failure of int  (* Numéro du premier coup illégal *)


(* Vérifie si 'state' mène à un état gagnant selon un type de jeu
   et un fichier solution (et exit 0).
   Sinon affiche le dernier état après 'n' coups valide (et exit n) *)
val check_game : Game.game -> State.state -> string -> 'a
