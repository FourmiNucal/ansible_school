# Mon script (SG)
## ligne 1 à 37
- ne sert qu'à donner la command help, et vérifie les 
trois paramètres en entré (et le fait qu'il y en a 3)

## ligne 39 à 47
- variables utile 

## Function server
- Elle prend les packages du bon server en paramètre pour installer le bon serveur web et s'assurer de faire la bonne config dépendant du server et du language de programmation selectionné.

## Function database
- Elle prend en paramètre les packages de la bonne BD. Les installe puis crée un user et une base de données test.

## Function language
- Elle prend en paramètre les packages des languages de programmation. Elle les installe et fait les manipulations avec leur config si besoin.

## ligne 122 à 141
- appel des fonctions et vérification de leur bon fonctionnement avec un message d'erreur au besoin.