Rapport
=======

## Sommaire

- [Identifiants](#identifiants)
- [Fonctionnalités](#fonctionnalités)
- [Compilation et exécution](#compilation-et-exécution)
- [Découpage modulaire](#découpage-modulaire)
- [Organisation du travail](#organisation-du-travail)
- [Misc](#misc)

----

## Identifiants

|  Name   | First name | Student number | Username |
|:-------:|:----------:|:--------------:|:--------:|
| Baroudi |   Hazim    |    22006563    | @baroudi |
| Timeus  |    Ryan    |    22001653    | @timeus  |

## Fonctionnalités

`XpatSolver` implémente les fonctionnalités suivantes:

### Projet minimal

- Valider une solution existante \
  `XpatSolver` avec comme arguments `<game>.<seed> -check <fic>` vérifie si `fic` est une solution pour la partie `<game>.<seed>`. \
  Par exemple `./run fc.1 -check fc1.sol`.

- Recherche automatique de solutions \
  `XpatSolver` avec comme arguments `<game>.<seed> -search <fic>` recherchera une solution pour une partie `<game>.<seed>`. Si une solution existe alors elle sera écrite dans `fic`. \
  Par exemple `./run bd.12 -search bd12.sol`.
  > Par default la commande `./run <game>.<seed>` fait la même chose mais écrit la solution dans `out.sol`.

  > Tous les fichiers solutions générés se trouve dans le répertoire `solution_file`.


## Compilation et exécution

La compilation se fait via `make` qui est seulement utilisé pour abréger les commandes `dune`:

- `make` sans argument lancera la compilation `dune` de `XpatSolver.exe`

- `make byte` lancera la compilation `dune` de `XpatSolver.bc`

- `make clean` pour effacer le répertoire provisoire `_build` produit par `dune` lors de ses compilations.
- `make clean_all` comme `make clean` mais supprime également le répertoire **solution_file**

> Si `make` n'est pas installé alors `dune build src/XpatSolver.exe` lancera la compilation `dune` de `XpatSolver.exe` et `dune clean` pour effacer le répertoire provisoire `_build`

Enfin pour lancer `XpatSolver` :

- `dune exec src/XpatSolver.bc arg1 arg2` si la compilation a été faites via `make byte`

- `./run arg1 arg2` si la compilation a été faites via `make`

Exemples d'exécution de `XpatSolver`:

```bash
# Vérifie si "fc1.sol" est un fichier solution pour la partie fc.123
./run fc.1 -check fc1.sol

# Cherche une solution pour la partie bd.12 et l'écrit dans "bd12.sol" si elle existe
./run bd.12 -search bd12.sol

# Cherche une solution pour la partie st.8 et l'écrit dans "out.sol" si elle existe
./run st.8
```

## Découpage modulaire

- [`PArray`](src/PArray.ml) utilise des tableaux impératifs en interne et forçant des recopies avant toute écriture.

- [`XpatRandom`](src/XpatRandom.ml) permet de générer une permutation de 52 entier à partir d'une graine.

- [`Card`](src/Card.ml) modélise les cartes utilisé par `State`

- [`Fifo`](src/Fifo.ml) représente une structure fonctionelle de type First-In First-Out

- [`XpatSolver`](src/XpatSolver.ml) initie le programme en lisant les arguments donnés par la ligne de commande et exécute l'action demandé.

### Modules additionnelles

- [`IOSystem`](src/IOSystem.ml) s'occupe de toutes les lectures et écritures dans un fichier. \
  En particulier il peut convertir un fichier en une liste de coups **à la condition qu'il soit bien formater**, à l'inverse il peut écrire une liste de coups dans un fichier avec le format habituel demandé.

- [`Game`](src/Game.ml) stocke les types de parties acceptées par `XpatSolver` et toutes les opérations qui dépendent de la partie choisit comme par exemple récuperer le **nombre de colonne** nécessaires ou encore à **quelles conditions** une carte peut être déplacée sur une colonne.

- [`State`](src/State.ml) est un module important, il permet la modélisation d'un **état** ainsi que des **coups**. Ce module implémente toutes les opérations sur un état telles que:
  - Récuperer l'état initial d'une partie.
  - Passer d'un état à un autre en exécutant un coup via le type `move` après avoir vérifié si celui-ci était valide.
  - La normalisation d'un état.
  - L'affichage d'un état.
  - Comparaison de deux états.
  - Vérification si l'état est un état gagnant.
  - Récuperer les voisins d'un état, c'est-à-dire récuperer tous les états accessible.

- [`CheckGame`](src/CheckGame.ml) effectue tous les coups contenue dans une liste (donnée par `IOSystem`) tant qu'ils sont valides et détermine donc si cette liste de coups amène à un état gagnant ou non.

- [`SearchGame`](src/SearchGame.ml) implémente notre algorithme de recherche automatique de solution basé sur l'algorithme [A*](https://en.wikipedia.org/wiki/A*_search_algorithm). Ce module utile les modules `States` et `Nodes` (obtenus via `Set.Make`) et des fonctions d'heuristiques, A* se basant sur deux ensembles (**open_set** qui est l'ensemble des états à visiter, modélisé par `Nodes` et **close_set** qui est l'ensemble des états déjà visités, modélisé par `States`) et une fonction d'heuristique. Il détermine ainsi s'il existe une solution pour une partie.


## Organisation du travail

## Partie 1

#### **Hazim**

Dans la première partie j'ai commencé à travailler sur le modules `XpatRandom` et a donc codé la fonction `shuffle` de ce module. 

Pendant que Ryan travallait sur la modélisation d'un état, je me suis occupé de l'amélioration du modules `Fifo` pour le rendre en temps constant en moyen.

Une fois que cela a été fait, j'ai travaillé sur le module `IOSystem` pour preparer le terrain pour Ryan.

#### **Ryan**

J'ai commencé par la création des types dont on avait besoin pour la modélisation des états, suite à ça j'avais un résultat satisfaisant pour l'état initial d'une partie.

J'ai donc fais en sorte de lire un fichier à l'aide d'Hazim qui m'a guidé dans le choix des fonctions de la bibliothèque standard. 

Enfin j'ai passé du temps sur les fonctions pour l'execution des coups et sur la validation d'un fichier solution.

## Partie 2

#### **Hazim**

Pour cette seconde partie avec Ryan on a d'abord réfléchi sur l'approche de la recherche de solutions. On en a conclut qu'un algorithme basé sur A* était une idée intéressante. Pour A* on avait besoin de fonctions d'heuristiques, j'ai donc commencé à réflechir sur ce sujet pour aboutir à plusieurs heuristiques équilibrées par des coefficients.

Après avoir aidé Ryan sur l'amélioration de A*, j'ai regardé les extensions proposées, je me suis intéressé a l'extension qui consiste à convertir un fichier solution de notre programme en un fichier de sauvegarde de `Xpat2`.
J'ai donc regardé le code source de `Xpat2` et j'ai essayé de faire cette conversion, en vain sans réussite. Le plus dur étant la conversion en format portable et de bien comprendre comment `Xpat2` faisait celle-ci. Mon travail se trouve dans la branche `partie-2`.

#### **Ryan**

Juste après le premier rendu on a donc discuté sur l'approche de cette deuxième partie et j'ai rapidement fais l'écriture dans un fichier. Je me suis attaqué à la comprehension de A* puis à coder cette algorithme, je me suis occupé de récuperer tous les voisins d'un état et grâce aux heuristiques qu'Hazim avaient déjà faites A* était fini.

Les premiers tests n'etaient pas satisfaisants, j'ai donc passé du temps sur l'amélioration de A*, il fallait changer le type de nos données pour stocker les noeuds de notre graphe (voir [misc](#misc)) avec Hazim on a abouti sur le même principe que pour `States` on a donc choisit `Nodes` obtenu via `Set.Make` qui nous a permit d'avoir des résultats très satisfaisant du fait que les opérations sont logarithmique. Le reste du temps j'ai testé beaucoup de parties pour optimiser les coefficients des heuristiques et valider un maximum de parties.

## Misc

Pour améliorer A* on a beaucoup réfléchit à des structures satisfaisantes comme des [binary heap](https://en.wikipedia.org/wiki/Binary_heap) ou des arbres. Nous sommes tombé sur le module externe [`Psq`](https://ocaml.org/p/psq/0.2.0) qui faisait exactement ce qu'on voulait. Il aurait été intéressant de tester notre algorithme avec ce module.

Une autre idée d'amélioration de notre algorithme de recherche était de changer les coefficients des heuristiques pendant la rechercher elle même quand celle-ci prend trop de temps.