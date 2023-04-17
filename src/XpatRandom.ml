let randmax = 1_000_000_000 


let reduce n limit =
  Int.(of_float (to_float n /. to_float randmax *. to_float limit))


let check_seed seed =
  if seed > 0 && seed < randmax then seed
  else assert false


(* Retourne la liste des 55 premières paires selon l'algorithme proposée *)
let creation_paire graine =
  let rec creation m l2 dernier avant_dernier=
    match m with
    | 0 -> l2
    | m ->
      match dernier,avant_dernier with
      | (d1, d2), (a1, a2) ->
        let r1 =(d1 + 21) mod 55 in
        let r2 = a2 - d2 in
        if r2 >= 0 then
          creation (m - 1) ((r1, r2) :: l2) (r1, r2) dernier
        else
          creation (m - 1) ((r1, r2+randmax) :: l2) (r1, r2+randmax) dernier
  in creation 53 [(21 mod 55, 1); (0, graine)] (21 mod 55, 1) (0, graine)


(* Renvoie une liste de paires trié selon la première composante. *)
let tri_paire l =
  List.sort (fun (a, _)(c, _) -> Stdlib.compare a c) l


(* Renvoie une sous liste de la position n a la position m *)
let separate l n m =
  let _, l = List.split (List.init (m - n) (fun i -> List.nth l (i + n))) in l


(* Renvoie la différence de n1, n2 (différence selon l'algorithme) *)
let difference n1 n2 =
  if n2 <= n1 then
    n1 - n2
  else
    n1 - n2 + randmax


(* Renvoie une Fifo remplie depuis une liste *)
let remplissage l =
  Fifo.of_list l


(* Cette fonction ,produit n tirages successifs  *)
let rec tirage_successifs n f1 f2 =
  match Fifo.pop f1,Fifo.pop f2 with
  |(n1, f1),(n2, f2) ->
    match difference n1 n2 with
    | d ->
      if n = 1 then 
        (d, Fifo.push n2 f1, Fifo.push d f2)
      else 
        tirage_successifs (n - 1) (Fifo.push n2 f1) (Fifo.push d f2)


(* Supprime, l'élément d'indice i de l et le retourne avec la nouvelle liste *)
let remove_from_list l i =
  let rec remove l1 l2 n =
    match l1 with
    | [] -> raise Not_found
    | h :: t ->
      if n = 0 then
        h, List.rev_append l2 t
      else 
        remove t (h :: l2) (n - 1)
  in remove l [] i


(** Renvoie un indice entre 0 et 51 selon un tirage *)
let get_pos n f1 f2 =
  match tirage_successifs 1 f1 f2 with
  | d, f1, f2 -> reduce d n, f1, f2


(** Cette fonction créer les permutations finales *)
let permutation f1 f2 =
  let rec permutation_bis l1 l2 f1 f2 n =
    if List.length l1 <> 52 then
      match get_pos n f1 f2 with
      | i, f1, f2 -> 
        match remove_from_list l2 i with
        | v, l2 -> permutation_bis (v :: l1) l2 f1 f2 (n - 1)
    else l1
  in permutation_bis [] (List.init 52 (fun i -> i)) f1 f2 52


let shuffle n =
    let paires = creation_paire n in
    let paires = tri_paire paires in
    let paires_trie_0_24 =separate paires 0 24 in
    let paires_trie_24_55 = separate paires 24 55 in
    let f1 = remplissage paires_trie_24_55 in
    let f2 = remplissage paires_trie_0_24 in
    let (d,f1,f2)= tirage_successifs 165 f1 f2 in
    permutation f1 f2
