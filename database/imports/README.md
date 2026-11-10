Les fichiers IMDb du dossier database/imports/ ne sont pas présents sur GitHub, car ils sont volumineux (environ 1,9 Go au total).

Ils sont exclus du dépôt grâce au fichier .gitignore.

Pour les récupérer, il suffit d'exécuter la commande suivante depuis la racine du projet :

bash scripts/download_imdb.sh

Ce script télécharge automatiquement les 7 fichiers IMDb nécessaires à l'importation des données dans la base MariaDB.
