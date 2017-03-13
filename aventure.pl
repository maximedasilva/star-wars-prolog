% Adapté de http://www.cis.upenn.edu/~mil_y_auszek/cis554-2011/Assignments/prolog-02-text-adventure.html by David Mil_y_auszek

% Prédicats dynamiques
/* Inventory */

:- dynamic possede/1.
:- dynamic je_suis_a/1, il_y_a/2, vivant/1.
:- retractall(il_y_a(_, _)), retractall(je_suis_a(_)), retractall(vivant(_)).


% Point de départ du joueur

je_suis_a(prairie).

/* Définition de l'environnement */

chemin(araignee, b, caverne).

chemin(caverne, u, araignee).
chemin(caverne, o, entree_caverne).

chemin(entree_caverne, e, caverne).
chemin(entree_caverne, s, prairie).

chemin(prairie, n, entree_caverne) :- il_y_a(torche, en_main).
chemin(prairie, n, entree_caverne) :-
        write('Pénétrer dans cette caverne sans torche ? Vous êtes fou ou quoi ?'), nl,
        !, fail.
chemin(prairie, s, batiment).

chemin(batiment, n, prairie).
chemin(batiment, o, taniere).

chemin(taniere, e, batiment).

chemin(armoire, o, batiment).

chemin(batiment, e, armoire) :- il_y_a(cle, en_main).
chemin(batiment, e, armoire) :-
        write('La porte semble fermée à clé.'), nl,
        fail.


/* Définition des objets du jeu */

il_y_a(rubis, araignee).
il_y_a(cle, entree_caverne).
il_y_a(torche, batiment).
il_y_a(epee, armoire).


/* Définition des NPC vivants */

vivant(araignee).


% Règles pour ramasser un objet

ramasser(X) :-
        il_y_a(X, en_main),
        write('Vous le tenez déjà !'),
        !, nl.

ramasser(X) :-
        je_suis_a(Endroit),
        il_y_a(X, Endroit),
        retract(il_y_a(X, Endroit)),
        assert(il_y_a(X, en_main)),
        write('OK.'),
        !, nl.

ramasser(_) :-
        write('Je ne vois rien ici.'),
        nl.

% Inventaire
inventaire :-
        possede(X),
        write('Inventaire:'),
        nl,
        write(X),
        fail.

% Règles pour laisser tomber un objet

deposer(X) :-
        il_y_a(X, en_main),
        je_suis_a(Endroit),
        retract(il_y_a(X, en_main)),
        assert(il_y_a(X, Endroit)),
        write('OK.'),
        !, nl.

deposer(_) :-
        write('Vous ne le tenez pas !'),
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
        write('Vous ne pouvez pas aller dans cette direction.').


/* Règle pour regarder autour de soi */

regarder :-
        je_suis_a(Endroit),
        decrire(Endroit),
        nl,
        lister_objets(Endroit),
        nl.


/* Ces règles définissent une boucle pour indiquer tous les objets
    qui se trouvent autour de vous */

lister_objets(Endroit) :-
        il_y_a(X, Endroit),
        write('Il y a un(e) '), write(X), write(' ici.'), nl,
        fail.

lister_objets(_).


/* Règles pour tuer les NPC */

attaquer :-
        je_suis_a(taniere),
        write('Mauvaise idée ! Vous venez d''être mangé(e) par le lion.'), nl,
        !, mourir.

attaquer :-
        je_suis_a(caverne),
        write('Ca ne marche pas. Cette araignée a les pattes trop solides.').

attaquer :-
        je_suis_a(araignee),
        il_y_a(epee, en_main),
        retract(vivant(araignee)),
        write('Vous frappez sauvagement l''araignée avec votre épée.'), nl,
        write('A chaque coup, un liquide gluant sorti de ses entrailles vous gicle à la figure.'), nl,
        write('Il semble bien que vous l''ayez tuée.'),
        nl, !.

attaquer :-
        je_suis_a(araignee),
        write('Frapper l''araignée avec vos petits poings n''a absolument aucun effet.'), nl.

attaquer :-
        write('Il n''y a rien à attaquer ici.'), nl.


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

decrire(prairie) :-
        il_y_a(rubis, en_main),
        write('Bravo ! Vous avez récupéré le rubis et gagné la partie'), nl,
        terminer, !.

decrire(prairie) :-
        write('Vous vous trouvez dans une prairie. Au nord se trouve l''entrée'), nl,
        write('d''une sombre caverne; au sud, un petit bâtiment.'), nl,
        write('Votre objectif est de récupérer le célèbre rubis de Bap-El-Paf'), nl,
        write('et de revenir ici en vie.'), nl.

decrire(batiment) :-
        write('Vous êtes dans un petit bâtiment. La sortie se trouve au nord.'), nl,
        write('Il y a une grille à l''ouest qui ne semble par fermée à clé.' ), nl,
        write('Il y a une plus petite porte à l''est.'), nl.

decrire(taniere) :-
        write('Vous êtes dans la tanière d''un lion qui semble plutôt affamé.'), nl,
        write('Il serait plus judicieux de partir vite...'), nl.

decrire(armoire) :-
        write('Il n''y a rien d''autre qu''une vieille armoire.'), nl.

decrire(entree_caverne) :-
        write('Vous êtes à l''entrée d''une sombre caverne. La sortie est au sud.'), nl,
        write('Il y a un large passage circulaire à l''est.'), nl.

decrire(caverne) :-
        vivant(araignee),
        il_y_a(rubis, en_main),
        write('L''araignée vous aperçoit avec le rubis et attaque !!'), nl,
        write('C''est un véritable carnage...'), nl,
        mourir.

decrire(caverne) :-
        vivant(araignee),
        write('Il y a une énorme araignée ici !'), nl,
        write('L''une de ses pattes velues est directement devant vous !'), nl,
        write('Vous pourriez l''utiliser pour grimper sur son dos.'), nl,
        write('Cela dit, la fuite est parfois est la meilleure solution...'), nl, !.

decrire(caverne) :-
        write('Beurk ! Il y a un énorme cadavre d''araignée ici.'), nl.

decrire(araignee) :-
        vivant(araignee),
        write('Vous êtes sur le dos de l''araignée. L''odeur est épouvantable.'), nl.

decrire(araignee) :-
        write('Vous êtes sur le dos d''une énorme araignée morte. C''est répugnant.'), nl.
