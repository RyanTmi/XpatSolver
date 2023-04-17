
(* IOSystem *)


(* Converti un fichier en 'coups' si celui-ci est correctement formaté. *)
val file_to_moves : string -> State.move list

(* Path du répertoire ou les fichiers solutions sont stockés. *)
val solution_directory : string

(* Écrit une liste de 'coups' dans un fichier. *)
val moves_to_file : string -> State.move list -> unit