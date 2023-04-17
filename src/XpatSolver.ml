
open XpatLib
open State
open Game

type mode =
  |  Check of string (* filename of a solution file to check *)
  | Search of string (* filename where to write the solution *)

type config = { mutable game : game; mutable seed: int; mutable mode: mode }

let config = { game = Freecell; seed = 1; mode = Search "out.sol" }

let split_on_dot name =
  match String.split_on_char '.' name with
  | [string1; string2] -> (string1, string2)
  | _ -> raise Not_found


let set_game_seed name =
  try
    let (sname, snum) = split_on_dot name in
    config.game <- of_string sname;
    config.seed <- int_of_string snum |> XpatRandom.check_seed
  with _ -> failwith ("Error: <game>.<number> expected, with <game> in "^
                      "FreeCell Seahaven MidnightOil BakersDozen"^
                      "<number> in [1, 999_999_999]")


let treat_game conf =
  let permut = XpatRandom.shuffle conf.seed in
  let state = get_initial_state conf.game permut in
  let game_name = to_string conf.game in
  Printf.printf "Configuration initiale pour %s %d:\n" game_name conf.seed;
  print_newline (); State.to_string state; print_newline ();
  match conf.mode with
  | Check file_name -> CheckGame.check_game conf.game state file_name
  | Search file_name -> SearchGame.search_game conf.game state file_name


let main () =
  Arg.parse
    [("-check", String (fun filename -> config.mode <- Check filename),
        "<filename>:\tValidate a solution file");
     ("-search", String (fun filename -> config.mode <- Search filename),
        "<filename>:\tSearch a solution and write it to a solution file")]
    set_game_seed (* pour les arguments seuls, sans option devant *)
    "XpatSolver <game>.<number> : search solution for Xpat2 game <number>";
  treat_game config

let _ = if not !Sys.interactive then main () else ()
