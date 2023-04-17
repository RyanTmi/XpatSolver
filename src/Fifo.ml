(** A FIFO structure (First-In First-Out),
    implemented in functional style
    (NB: the Queue module of OCaml stdlib is imperative)

    NB: l'implémentation fournie initialement ci-dessous est inefficace,
    l'améliorer (tout en restant fonctionnel). Par exemple on peut utiliser
    une paire de listes pour implémenter ['a t].

*)

type 'a t ='a list * 'a list


let empty =([], [])


let push x (l1, l2) = (x :: l1, l2)


let pop (l1, l2) =
  match l2 with
  | [] ->
    begin
    match List.rev l1 with
    | [] -> raise Not_found
    | h :: t -> h, ([], t)
    end
  | h :: t -> h, (l1, t)


let of_list l = [], List.rev l


let to_list (l1, l2) = l2 @ List.rev l1