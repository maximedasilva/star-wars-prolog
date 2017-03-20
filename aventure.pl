% Adapté de http://www.cis.upenn.edu/~mil_y_auszek/cis554-2011/Assignments/prolog-02-text-adventure.html by David Mil_y_auszek

% Prédicats dynamiques

:- dynamic je_suis_a/1, il_y_a/2, vivant/1, possede/1, boire/1.
:- retractall(il_y_a(_, _)), retractall(je_suis_a(_)), retractall(vivant(_)).


% Point de départ du joueur

je_suis_a(alderran).

/* Définition de l'environnement */

chemin(chasseur_Tie, b, corellia).

chemin(corellia, u, chasseur_Tie).
chemin(corellia, o, geonosis).

chemin(geonosis, e, corellia).
chemin(geonosis, s, alderaan).

chemin(alderaan, n, geonosis) :- il_y_a(munitions, en_main).
chemin(alderaan, n, geonosis) :-
        write('Pénétrer dans le secteur contrôllé par l\'empire sans munitions est une mission suicide, refusé!'), nl,
        !, fail.
chemin(alderaan, s, kamino).

chemin(kamino, n, alderaan).
chemin(kamino, o, hoth).

chemin(hoth, e, kamino).

chemin(mustafar, o, kamino).
chemin(kamino, e, mustafar) :- il_y_a(autorisation de lEmpire, en_main).
chemin(kamino, e, mustafar) :-
        write('Im'), nl,
        fail.
/* Vie de départ du joueur*/

vie(5).

/* Définition des objets du jeu */

il_y_a(rubis, chasseur_Tie).
il_y_a(autorisation de lEmpire, geonosis).
il_y_a(munitions, kamino).
il_y_a(epee, mustafar).
il_y_a(potion, kamino).


/* Définition des NPC vivants */

vivant(chasseur_Tie).


% Règles pour ramasser un objet

ramasser(X) :-
        il_y_a(X, en_main),
        write('Il est déjà dans votre vaisseau!'),
        !, nl.

ramasser(X) :-
        je_suis_a(Endroit),
        il_y_a(X, Endroit),
        retract(il_y_a(X, Endroit)),
        assert(il_y_a(X, en_main)),
        write('OK.'),
        !, nl.

ramasser(X) :-
        je_suis_a(Endroit),
        il_y_a(X,Endroit),
        il_y_a(_, en_main),
        retract(il_y_a(X, Endroit)),
        assert(possede(X)),
        write('Objet ajouté à l''inventaire'),
        nl.


ramasser(_) :-
        write('Ce secteur semble vide'),
        nl.

% Inventaire

inventaire :-
        possede(X),
        write('Inventaire:'),
        nl,
        lister_inventaire.

inventory:-
  write('Vous ne possédez rien'),nl.

lister_inventaire:-
  possede(X),
  tab(2),write(X),nl,
  fail.
lister_inventaire.

% Règles pour laisser tomber un objet

deposer(X) :-
        il_y_a(X, en_main),
        je_suis_a(Endroit),
        retract(il_y_a(X, en_main)),
        assert(il_y_a(X, Endroit)),
        write('OK.'),
        !, nl.

deposer(_) :-
        write('Vous ne le l''avez pas !'),
        nl.

/* These rules define the direction letters as calls to aller/1. */

n :- aller(n).

s :- aller(s).

e :- aller(e).

o :- aller(o).

b :- aller(b).

u :- aller(u).

/* Règle pour se déEndroitr dans une direction donnée */

aller(Direction) :-
        je_suis_a(Ici),
        chemin(Ici, Direction, Labas),
        retract(je_suis_a(Ici)),
        assert(je_suis_a(Labas)),
        !, regarder.

aller(_) :-
        write('Vous ne pouvez pas aller dans cette direction, vous êtes déjà sur la bordure extérieure du système.').


/* Règle pour regarder autour de soi */

regarder :-
        je_suis_a(Endroit),
        decrire(Endroit),
        nl,
        lister_objets(Endroit),
        nl.


/* Ces règles définissent une bouautorisation de l'Empire pour indiquer tous les objets
    qui se trouvent autour de vous */

lister_objets(Endroit) :-
        il_y_a(X, Endroit),
        write('Il y a un(e) '), write(X), write(' ici.'), nl,
        fail.

lister_objets(_).


/* Règles pour tuer les NPC */

attaquer :-
        je_suis_a(hoth),
        write('Mauvaise idée ! Vous venez d''être mangé(e) par le lion.'), nl,
        !, mourir.

attaquer :-
        je_suis_a(corellia),
        write('Ca ne marche pas. Cette araignée a les pattes trop solides.').

attaquer :-
        je_suis_a(chasseur_Tie),
        il_y_a(epee, en_main),
        retract(vivant(chasseur_Tie)),
        write('Vous frappez sauvagement l''araignée avec votre épée.'), nl,
        write('A chaque coup, un liquide gluant sorti de ses entrailles vous giautorisation de l'Empire à la figure.'), nl,
        write('Il semble bien que vous l''ayez tuée.'),
        nl, !.

attaquer :-
        je_suis_a(chasseur_Tie),
        write('Frapper l''araignée avec vos petits poings n''a absolument aucun effet.'), nl.

attaquer :-
        write('Il n''y a rien à attaquer ici.'), nl.

%Boire potion pour regagner vie

boire(potion) :-
        possede(potion),
        retract(possede(potion)),
        assert(vie(5)),
        write('Vous buvez la potion et regagnez votre vie'), nl.

boire(potion) :-
        possede(potion),
        vie(5),
        write('Vous êtes déja en pleine forme !'), nl.

/* Règle qui définit la mort */

mourir :-
        !, terminer.


/* Règle pour afficher un message final */

terminer :-
        nl,
        write('La partie est terminée. Tapez la commande "halt."'),
        nl, !.


/* Règle qui affiche le mode d'emploi du jeu */

mode_emploi :-
        nl,
        write('Entrez les commandes avec la syntaxe Prolog standard.'), nl,
        write('Les commandes disponibles sont :'), nl,
        write('demarrer.          -- pour commencer une partie.'), nl,
        write('n. s. e. o. u. b.  -- pour aller dans une direction.'), nl,
        write('ramasser(Objet).   -- pour ramasser un objet.'), nl,
        write('deposer(Objet).    -- pour laisser tomber un objet.'), nl,
        write('regarder.          -- pour regarder de nouveau autour de vous.'), nl,
        write('attaquer.          -- pour attaquer un ennemi.'), nl,
        write('mode_emploi.       -- pour afficher le mode d''emploi de nouveau.'), nl,
        write('terminer.          -- pour terminer la partie.'), nl,
        nl.


/* Règle qui démarre le jeu. */

demarrer :-
        mode_emploi,
        regarder.


/* Règles pour afficher la ou les description(s) des piéces */

decrire(alderaan) :-
        il_y_a(rubis, en_main),
        write('Bravo ! Vous avez récupéré le rubis et gagné la partie'), nl,
        terminer, !.

decrire(alderaan) :-
        write('Vous vous trouvez dans une alderaan. Au nord se trouve l''entrée'), nl,
        write('d''une sombre corellia; au sud, un petit bâtiment.'), nl,
        write('Votre objectif est de récupérer le célèbre rubis de Bap-El-Paf'), nl,
        write('et de revenir ici en vie.'), nl.

decrire(kamino) :-
        write('Vous êtes dans un petit bâtiment. La sortie se trouve au nord.'), nl,
        write('Il y a une grille à l''ouest qui ne semble par fermée à clé.' ), nl,
        write('Il y a une plus petite porte à l''est.'), nl.

decrire(hoth) :-
        write('Vous êtes dans la tanière d''un lion qui semble plutôt affamé.'), nl,
        write('Il serait plus judicieux de partir vite...'), nl.

decrire(mustafar) :-
        write('Il n''y a rien d''autre qu''une vieille mustafar.'), nl.

decrire(geonosis) :-
        write('Vous êtes à l''entrée d''une sombre corellia. La sortie est au sud.'), nl,
        write('Il y a un large passage circulaire à l''est.'), nl.

decrire(corellia) :-
        vivant(chasseur_Tie),
        il_y_a(rubis, en_main),
        write('L''araignée vous aperçoit avec le rubis et attaque !!'), nl,
        write('C''est un véritable carnage...'), nl,
        mourir.

decrire(corellia) :-
        vivant(chasseur_Tie),
        write('Il y a une énorme araignée ici !'), nl,
        write('L''une de ses pattes velues est directement devant vous !'), nl,
        write('Vous pourriez l''utiliser pour grimper sur son dos.'), nl,
        write('Cela dit, la fuite est parfois est la meilleure solution...'), nl, !.

decrire(corellia) :-
        write('Beurk ! Il y a un énorme cadavre d''araignée ici.'), nl.

decrire(chasseur_Tie) :-
        vivant(chasseur_Tie),
        write('Vous êtes sur le dos de l''araignée. L''odeur est épouvantable.'), nl.

decrire(chasseur_Tie) :-
        write('Vous êtes sur le dos d''une énorme araignée morte. C''est répugnant.'), nl.
