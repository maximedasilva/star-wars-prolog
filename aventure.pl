%Encodage utf8

:- encoding(utf8).

% Prédicats dynamiques

:- dynamic je_suis_a/1, il_y_a/2, vivant/1, possede/1, argent/1, a_vendre/2, est_installe/1.
:- retractall(il_y_a(_, _)), retractall(je_suis_a(_)), retractall(vivant(_)).


% Point de départ du joueur
%Infos sur le joueur

vie(5).
argent(3000).
je_suis_a(alderaan).

/* Définition de l'environnement */
chemin(chasseur_Tie, b, corellia).
chemin(corellia, u, chasseur_Tie).

chemin(geonosis, e, corellia):- possede(munitions).
chemin(corellia, o, geonosis):-
        write('Pénétrer dans le secteur contrôllé par l\'empire sans munitions est une mission suicide, refusé!'), nl,
        !, fail.


chemin(geonosis, s, alderaan).
chemin(alderaan, n, geonosis).

chemin(alderaan, s, kamino).
chemin(kamino, n, alderaan).

chemin(kamino, o, hoth).
chemin(hoth, e, kamino).

chemin(mustafar, o, kamino).
chemin(kamino, e, mustafar) :- possede(plan_etoile_noire).
chemin(kamino, e, mustafar) :-
        write('Impossible de pénétrer sur ce secteur sans autorisations, refusé'), nl,
        fail.

chemin(geonosis,o,tatooine).
chemin(tatooine,e,geonosis).

chemin(mustafar,s,etoileNoire).
chemin(etoileNoire,n,mustafar).

chemin(chasseur_Tie,n,yavin_IV).
chemin(yavin_IV,s,chasseur_Tie).

chemin(tatooine,u,naboo).
chemin(naboo,b,tatooine).


/* Définition des noms des objets */
nom(munitions) :- write('Munitions pour le canon du X-Wing'),nl.
nom(plan_etoile_noire) :- write('Plans de l''Etoile Noire'),nl.
nom(propulseur) :- write('Un propulseur vous permettant d''atteindre la vitesse de la lumière'),nl.
nom(canon_blaster) :- write('Ce canon redoutable est l''arme adéquate pour abattre n''importe quel chasseur'),nl.

/* Définition de la boutique*/

boutique(hoth).

/* Objets disponibles dans les boutiques */

a_vendre(propulseur, 2000).
a_vendre(munitions,100).
a_vendre(canon_blaster,1000).

/* Définition des équipements disponibles pour le vaisseau */
equipement(canon_blaster).
equipement(propulseur).
equipement(munitions).
equipement(invisibilite).

/* Définition des objets du jeu */
il_y_a(plan_etoile_noire, geonosis).
il_y_a(munitions, kamino).
il_y_a(munitions,hoth).
il_y_a(propulseur,hoth).
il_y_a(canon_blaster,hoth).
il_y_a(invisibilite,naboo).


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
        write('Vous venez de récupérer '), write(X),
        !, nl.

ramasser(_) :-
        write('Ce secteur semble vide'),
        nl.
        
% Liste les objets de l'Inventaire
inventaire :-
    write('Argent:'), nl,
    argent(C),
    write(C), nl, nl,
    write('Objets présents dans le vaisseau :'), nl,
    possede(X),
    nom(X), write(' <'), write(X), write('> '), nl,
    est_installe(X), write('(installe)'),nl,
    fail,!.

inventaire.

/* Règles qui définissent comment installer un objet */

installer(X) :-
        possede(X),
        equipement(X),
        est_installe(X),
        nom(X), write(' est déjà installé.'), nl,!.

installer(X) :-
        possede(X),
        equipement(X),
        X == munitions,
        write('Vous ne pouvez pas installer de munitions'),nl,!.

installer(X) :-
        possede(X),
        equipement(X),
        assert(est_installe(X)),
        nom(X), write(' a été installé avec succès.'), nl,!.

installer(X) :-
        possede(X),
        nom(X), write(' ne peut pas être installé sur votre vaisseau.'), nl,!.

installer(X) :-
        write('Vous ne possédez pas '), nom(X), nl,!.

installer(_) :-
        write('Vous ne possédez pas cet équipement...'), nl,!.

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
        retract(a_vendre(X,Prix)),
        retract(il_y_a(X, Endroit)),
        assert(possede(X)),
        write('Vous avez acheté '), nom(X), nl,
        consulter,!.

acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        il_y_a(X, Endroit),
        a_vendre(X, Prix),
        argent(C),
        C < Prix,
        write('Cet équipement est trop cher !'), nl,
        consulter,!.

acheter(X) :-
        je_suis_a(Endroit),
        boutique(Endroit),
        X,
        write('Cet objet n''est pas à vendre'), nl,
        consulter,!.

acheter(_) :-
        write('Il n''y a pas de boutique ici'), nl.

/* Règles pour consulter les objets de la boutique sans en acheter */
consulter :-
    je_suis_a(Endroit),
    boutique(Endroit),
    argent(C),
    write('Argent : '), write(C), nl, nl,
    write('Les items suivants sont disponibles :'), nl, nl,
    il_y_a(X, Endroit),
    a_vendre(X, Prix),
    nom(X), write(' <'), write(X), write('>'), write(' - '), write(Prix), nl,
    fail, !.

consulter :-
    je_suis_a(Endroit),
    boutique(Endroit),
    il_y_a(X, Endroit),
    a_vendre(X, Prix),
    Prix > 0,
    !.

consulter :-
    je_suis_a(Endroit),
    boutique(Endroit),
    write('Il n''y a rien à vendre ici !'), nl.

consulter :-
    write('Aucune boutique en vue.'), nl.

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
        nl.

scanner :-
        je_suis_a(Endroit),
        il_y_a(X, Endroit),
        write('Votre scanner vous indique qu''il y a un(e) '), write(X), write(' sur cette planète.'),
        !, nl.

scanner :- 
        write('Le radar reste muet.'),nl.

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
        write('scanner.           -- pour scanner les objets de la planète.'),nl,
        write('inventaire.        -- pour lister les objets que vous possédez.'),nl,
        write('consulter.         -- pour consulter les objets de la boutique.'),nl,
        write('acheter(Objet).    -- pour acheter un objet de la boutique.'),nl,
        write('installer(Objet).  -- pour installer un équipement sur votre vaisseau.'),nl,
        write('regarder.          -- pour regarder de nouveau autour de vous.'), nl,
        write('attaquer.          -- pour attaquer un ennemi.'), nl,
        write('mode_emploi.       -- pour afficher le mode d''emploi de nouveau.'), nl,
        write('terminer.          -- pour terminer la partie.'), nl,nl,

        write('L''Empire prépare une nouvelle attaque contre les populations libres de la Galaxie.'),nl,
        write('Sa nouvelle arme de destruction serait appelée Etoile Noire. '),nl,
        write('Vous êtes l''un des meilleurs pilotes de X-Wing de la Galaxie'),nl,
        write('Votre but sera de vous introduire dans l''Etoile Noire afin de la détruire.'),nl,
        write('Pour cela, il vous faudra réunir des équipements indispensables pour votre vaisseau : '),nl,
        write('un propulseur vous permettra de ne pas vous faire attraper aux abords de l''étoile Noire,'),nl,
        write('un canon vous sera indispensable pour ne pas périr contre les ennemis,'),nl,
        write('enfin, l''invisibilité vous permettra de contourner les détecteurs de la planète.'),nl,
        write('Vous devrez aussi récupérer les plans de l''Etoile Noire.'),nl,
        write('Votre mission sera dangereuse, prenez garde...'),nl,
        nl.


/* Règle qui démarre le jeu. */

demarrer :-
        mode_emploi,
        regarder.


/* Règles pour afficher la ou les description(s) des piéces */

decrire(alderaan) :-
        write('Alderaan est le QG principal des forces rebelles se battant contre l''Empire.'), nl,
        write('Son climat est doux et ses paysages charmants.'), nl,
        write('Malheureusement, Alderaan pourrait bientôt disparaître à cause de l''Empire...'), nl.

decrire(kamino) :-
        write('Kamino est une planète aquatique située au-delà des Territoires de la Bordure Extérieure, dans l''Espace Sauvage.'),nl,
        write('Ses immensités bleues peuvent parfois vous faire perdre la tête...'),nl,
        write('Il s''agit de la planète d''origine des Kaminoens.'), nl.

decrire(hoth) :-
        write('Comme son nom ne l''indique pas, Hoth est un monde recouvert de neige et de glace.'), nl,
        write('Constamment frappée par les météorites, elle n''a développé aucune forme de vie intelligente '),nl,
        write('mais possède néanmoins quelques formes de vie animales, comme le Tauntaun ou le Wampa.'),nl.

decrire(mustafar) :-
        write('Située loin dans la Bordure Extérieure, la planète volcanique Mustafar est '),nl,
        write('constamment en mouvement, attirée par deux planètes gazeuses.'), nl,
        write('Ses paysages n''ont pas l''air très acceuillants...'),nl.

decrire(geonosis) :-
        write('Monde rocheux situé à moins d''un parsec de Tatooine '), nl,
        write('Geonosis est une planète se trouvant au delà des frontières de la République Galactique.'), nl,
        write('Sa surface peu engageante est dominée par les rochers, les crevasses et les déserts.'),nl.

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
        write('Corellia est pour beaucoup synonyme de technologie et de voyage spatial.'),nl,
        write('Pour d''autres cette planète est le symbole des fauteurs de trouble et '), nl,
        write('de tout ce que l''univers compte de hors-la-loi.'),nl.

decrire(chasseur_Tie) :-
        vivant(chasseur_Tie),
        possede(munitions),
        write('Un groupe de chasseurs Tie de l''Empire vous repère et commence à vous attaquer !'),nl,
        write('Heureusement vous disposez de votre canon et de vos munitions et vous les détruisez'), nl.

decrire(chasseur_Tie) :-
        write('Un groupe de chasseurs Tie de l''Empire vous repère et commence à vous attaquer !'), nl,
        write('Vous n''avez aucun moyen de vous défendre... Leurs canons sont surpuissants, votre vaisseau vole en éclats'), nl,
        mourir.
decrire(naboo).
decrire(tatooine).
decrire(yavin_IV).
decrire(etoileNoire).
