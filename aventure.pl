% Prédicats dynamiques

:- dynamic je_suis_a/1, il_y_a/2, vivant/1, possede/1, boire/1, argent/1, a_vendre/1, est_installe/1.
:- retractall(il_y_a(_, _)), retractall(je_suis_a(_)), retractall(vivant(_)).


% Point de départ du joueur
%Infos sur le joueur
je_suis_a(alderaan).



vie(5).
argent(3000).

/* Définition de l'environnement */
chemin(chasseur_Tie, b, corellia).

chemin(corellia, u, chasseur_Tie).
chemin(chasseur_Tie,n,yavin_IV).
chemin(yavin_IV,s,chasseur_Tie).

chemin(corellia, o, geonosis).

chemin(geonosis, e, corellia):- il_y_a(munitions,possede).
chemin(geonosis,e, corellia):-
        write('Aller dans la zone controllee par l''empire sans munitions ou canon laser est une mission suicide, refusé'),nl,
        fail.
chemin(geonosis, s, alderaan).
chemin(geonosis,o,tatooine).
chemin(tatooine,e,geonosis).
chemin(tatooine,u,rebelle).
chemin(rebelle,b,tatooine).
chemin(alderaan, n, geonosis).

chemin(alderaan, s, kamino).

chemin(kamino, n, alderaan).
chemin(kamino, b, hoth).

chemin(hoth, u, kamino).

chemin(mustafar, o, kamino).
chemin(kamino, e, mustafar) :- il_y_a(autorisation_de_lEmpire, possede).
chemin(kamino, e, mustafar) :-
        write('Impossible de pénétrer sur ce secteur sans autorisations, refusé'), nl,
        fail.
/* Définition de la boutique

*/
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
il_y_a(rubis, yavin_IV).
il_y_a(autorisation_de_lEmpire, geonosis).
il_y_a(invisibilite,rebelle).
il_y_a(boutique2,tatooine).
il_y_a(boutique1,hoth).



/* Définition des NPC vivants */

vivant(chasseur_Tie).
vivant(rebelle)


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
        possede(_),
        write('Inventaire: '),
        nl,
        lister_inventaire.

inventaire:-
        write('Vous ne possédez rien'),nl.

lister_inventaire:-
        possede(X),
        tab(2),write(X),nl,
        fail.
        lister_inventaire.

/* Règles pour acheter un objet dans la boutique*/
acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        at(X, Endroit),
        a_vendre(X, Prix),
        credits(C),
        C >= Prix,
        retract(credits(C)),
        NewC is C-Prix,
        assert(credits(NewC)),
        retract(a_vendre(X, Prix)),
        retract(at(X, Endroit)),
        assert(possede(X)),
        write('Vous avez acheté '), X, nl,
        browse,!.

acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        at(X, Endroit),
        a_vendre(X, Prix),
        credits(C),
        C < Prix,
        write('Cet équipement est trop cher !'), nl,
        browse,!.

acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        X,
        write('Cet objet n''est pas à vendre'), nl,
        browse,!.

acheter(_) :-
        write('Il n''y a pas de boutique ici'), nl.

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
        write('Vous ne pouvez pas aller dans cette direction').


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
            write('Votre vaisseau est équipé de '), write(X), nl,
            fail.

lister_equipement().

lister_objets(Endroit) :-
        il_y_a(X, Endroit),
        write('Il y a un(e) '), write(X), write(' dans cette zone du système.'), nl,
        fail.

lister_objets(_).


/* Règles pour tuer les NPC */

attaquer :-
        je_suis_a(rebelle),

        write('Vous venez d''être capturé par les rebelles de naboo.'), nl,
        !, mourir.
attaquer :-
        je_suis_a(rebelle),
        possede(munitions),
        est_installe(canon_laser),
        retract(vivant(rebelle)),
        write('En attérissant à naboo vous tuez la faible résistance rebelle de '), nl,
        !, mourir.
attaquer :-
        je_suis_a(corellia),
        write('Comment voulez vous attaquer sans munitions?').

attaquer :-
        je_suis_a(chasseur_Tie),
        possede(munitions),
        est_installe(canon_laser),
        retract(vivant(chasseur_Tie)),
        write('Vous vous mettez en position de combat contre ce chasseur imperial'), nl,
        write('Un combat epique démarre, les coups de canon lasers fusent et après une énième manoeuvre, vous réussissez à vous placer derrière lui'), nl,
        write('Vous tirez, il explose dans un spectacle lumineux.'),
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
        write('Bravo ! Vous avez récupéré les plans de l''etoile de la mort et gagné la partie'), nl,
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
