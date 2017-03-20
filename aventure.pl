% Adapté de http://www.cis.upenn.edu/~mil_y_auszek/cis554-2011/Assignments/prolog-02-text-adventure.html by David Mil_y_auszek

% Prédicats dynamiques

:- dynamic je_suis_a/1, il_y_a/2, vivant/1, possede/1, boire/1, argent/1, a_vendre/1, est_installe/1.
:- retractall(il_y_a(_, _)), retractall(je_suis_a(_)), retractall(vivant(_)).


% Point de départ du joueur
%Infos sur le joueur


je_suis_a(alderran).

vie(5).
argent(3000).

/* Définition de l'environnement */

chemin(chasseur_Tie, b, corellia).

chemin(corellia, u, chasseur_Tie).
chemin(corellia, o, geonosis).

chemin(geonosis, e, corellia).
chemin(geonosis, s, alderaan).


chemin(alderaan, n, geonosis) :- il_y_a(munitions, possede).
chemin(alderaan, n, geonosis) :-
        write('Pénétrer dans le secteur contrôllé par l\'empire sans munitions est une mission suicide, refusé!'), nl,
        !, fail.
chemin(alderaan, s, kamino).

chemin(kamino, n, alderaan).
chemin(kamino, o, hoth).

chemin(hoth, e, kamino).

chemin(mustafar, o, kamino).
chemin(kamino, e, mustafar) :- il_y_a(autorisation_de_lEmpire, possede).
chemin(kamino, e, mustafar) :-
        write('Impossible de pénétrer sur ce secteur sans autorisations, refusé'), nl,

        fail.
/* Définition de la boutique*/

boutique(station).

/* Objets disponibles dans la boutique */

a_vendre(canon_laser, 1000).
a_vendre(bouclier, 3000).
a_vendre(boost, 2000).
a_vendre(munition,100).

/* Définition des équipements disponiblespour le vaisseau */
equipement(canon_laser).
equipement(bouclier).
equipement(boost).
equipement(munition).

/* Définition des objets du jeu */

il_y_a(rubis, chasseur_Tie).
il_y_a(fraise,alderaan).
il_y_a(autorisation_de_lEmpire, geonosis).
il_y_a(munitions, kamino).
il_y_a(epee, mustafar).
il_y_a(potion, kamino).


/* Définition des NPC vivants */

vivant(chasseur_Tie).


% Règles pour ramasser un objet

ramasser(X) :-
        possede(X),
        write('Il est déjà dans votre vaisseau!'),
        !, nl.

ramasser(X) :-
        je_suis_a(Endroit),
        il_y_a(X, Endroit),
        retract(il_y_a(X, Endroit)),
        assert(possede(X)),
        write('OK.'),
        !, nl.

ramasser(X) :-
        je_suis_a(Endroit),
        il_y_a(X,Endroit),
        il_y_a(_, possede),
        retract(il_y_a(X, Endroit)),
        assert(possede(X)),
        write('Objet ajouté à l''inventaire'),
        nl.

ramasser(_) :-
        write('Ce secteur semble vide'),
        nl.

% Inventaire

inventaire :-
    write('Dataries :'), nl,
    argent(C),
    write(C), nl, nl,
    write('Objets a bord'), nl,
    possede(X),
    name(X), write(' <'), write(X), write('> '), nl,
    est_installe(X), write('(Installe)'),nl,
    fail,!.

inventaire.

inventaire:-
        write('Vous ne possédez rien'),nl.


/* Règles pour acheter un objet dans la boutique*/
acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        il_y_a(X, Endroit),
        a_vendre(X, Prix),
        argent(C),
        C >= Prix,
        retract(argent(C)),
        NewC is C-Prix,
        assert(argent(NewC)),
        retract(a_vendre(X, Prix)),
        retract(il_y_a(X, Endroit)),
        assert(possede(X)),
        write('Vous avez acheté '), X, nl,
        regarder_boutique,!.

acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        il_y_a(X, Endroit),
        a_vendre(X, Prix),
        argent(C),
        C < Prix,
        write('Cet équipement est trop cher !'), nl,
        regarder_boutique,!.

acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        X,
        write('Cet objet n''est pas à vendre'), nl,
        regarder_boutique,!.

acheter(_) :-
        write('Il n''y a pas de boutique ici'), nl.

/* Règles pour voir les objets disponibles dans la boutique */

/* These rules describe how we regarder_boutique what is for a_vendre */

regarder_boutique :-
    je_suis_a(Endroit),
    boutique(Endroit),
    argent(C),
    write('Available argent: '), write(C), nl, nl,
    write('The following items are available for purchase:'), nl, nl,
    il_y_a(X, Endroit),
    a_vendre(X, Prix),
    name(X), write(' <'), write(X), write('>'), write(' - '), write(Prix), write(' argent'), nl,
    fail, !.

regarder_boutique :-
    je_suis_a(Endroit),
    boutique(Endroit),
    il_y_a(X, Endroit),
    a_vendre(X, Prix),
    Prix > 0,
    !.

regarder_boutique :-
    je_suis_a(Endroit),
    boutique(Endroit),
    write('There is nothing for a_vendre.'), nl.

regarder_boutique :-
    write('There isn''t a boutique here'), nl.


/* Règles pour installer un équipement */

installe(X) :-
        possede(X),
        equipement(X),
        est_installe(X),
        name(X), write(' is already est_installe.'), nl,!.

installe(X) :-
        possede(X),
        equipement(X),
        assert(est_installe(X)),
        name(X), write(' has been est_installe successfully.'), nl,!.

installe(X) :-
        possede(X),
        name(X), write(' cannot be est_installe on your ship.'), nl,!.

installe(X) :-
        write('You don''t have '), name(X), nl,!.

installe(_) :- 
        write('You don''t have that object'), nl,!.


% Règles pour laisser tomber un objet

deposer(X) :-
        il_y_a(X, possede),
        je_suis_a(Endroit),
        retract(il_y_a(X, possede)),
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


/* Ces règles définissent une boucle pour indiquer tous les objets
    qui se trouvent autour de vous */
lister_equipement() :-
            il_y_a(X, possede),
            write('Il y a un(e) '), write(X), write(' dans vos mains.'), nl,
            fail.

lister_equipement().

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
        write('A chaque coup, un liquide gluant sorti de ses entrailles vous giautorisation_de_lEmpire à la figure.'), nl,
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
        possede(rubis),

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
        il_y_a(rubis, possede),
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
