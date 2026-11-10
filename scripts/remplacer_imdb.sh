
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BASE_ACTUELLE="cinema"
BASE_NOUVELLE="cinema_next"
ESPACE_MIN_GO=40

export MSYS_NO_PATHCONV=1

echo "======================================"
echo " REMPLACEMENT COMPLET DES DONNEES IMDb"
echo "======================================"

# 1. Vérifier les fichiers nécessaires
if [ ! -f database/schema.sql ]; then
  echo "ERREUR : database/schema.sql introuvable."
  exit 1
fi

if [ ! -f scripts/_import_common.sh ]; then
  echo "ERREUR : _import_common.sh introuvable."
  exit 1
fi

# 2. Vérifier l'espace disque
ESPACE_LIBRE_KO=$(df -Pk /c | awk 'NR==2 {print $4}')
ESPACE_MIN_KO=$((ESPACE_MIN_GO * 1024 * 1024))

echo "Espace libre : $((ESPACE_LIBRE_KO / 1024 / 1024)) Go"

if [ "$ESPACE_LIBRE_KO" -lt "$ESPACE_MIN_KO" ]; then
  echo "ERREUR : espace disque insuffisant."
  echo "Il faut au moins ${ESPACE_MIN_GO} Go libres."
  echo "La base actuelle n'a pas été modifiée."
  exit 1
fi

# 3. Vérifier que MariaDB fonctionne
docker compose exec -T db sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -e "SELECT 1;"' \
  >/dev/null

# 4. Vérifier que la nouvelle base n'existe pas
EXISTE=$(docker compose exec -T db sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "
  SELECT COUNT(*)
  FROM information_schema.SCHEMATA
  WHERE SCHEMA_NAME = '\''cinema_next'\'';"')

EXISTE=$(printf '%s' "$EXISTE" | tr -d '\r[:space:]')

if [ "$EXISTE" != "0" ]; then
  echo "ERREUR : cinema_next existe déjà."
  echo "Aucune base ne sera supprimée automatiquement."
  exit 1
fi

# 5. Vérifier les fichiers IMDb
echo "Vérification des fichiers IMDb..."

docker compose exec -T db sh -s <<'CHECK_FILES'
set -eu

for fichier in \
  title.basics.tsv.gz \
  name.basics.tsv.gz \
  title.akas.tsv.gz \
  title.ratings.tsv.gz \
  title.episode.tsv.gz \
  title.principals.tsv.gz \
  title.crew.tsv.gz
do
  test -s "/var/lib/mysql-files/$fichier" || {
    echo "Fichier manquant : $fichier"
    exit 1
  }
done

echo "Les 7 fichiers IMDb sont présents."
CHECK_FILES

# 6. Créer la nouvelle base et autoriser l'import
echo "Création de cinema_next..."

docker compose exec -T db sh -s <<'CREATE_DB'
set -eu

mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" <<SQL
CREATE DATABASE cinema_next
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
SQL

# Vérifier le nom de l'utilisateur SQL
case "$MARIADB_USER" in
  *[!a-zA-Z0-9_]* | "")
    echo "Nom utilisateur MariaDB non pris en charge."
    exit 1
    ;;
esac

mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" <<SQL
GRANT ALL PRIVILEGES ON cinema_next.*
TO '$MARIADB_USER'@'%';
SQL
CREATE_DB

# 7. Recréer les 12 tables
echo "Création des 12 tables..."

docker compose exec -T db sh -c \
  'mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" cinema_next' \
  < database/schema.sql

# 8. Importer dans cinema_next
export IMDB_DATABASE="$BASE_NOUVELLE"

debut=$SECONDS

importer() {
  local script="$1"
  echo
  echo "======================================"
  echo "Importation : $script"
  echo "======================================"

  bash "scripts/$script"
}

# Tables principales
importer import_oeuvres.sh
importer import_personnes.sh

# Tables de référence
importer import_genres.sh
importer import_professions.sh

# Associations et autres données
importer import_oeuvre_genres.sh
importer import_personne_professions.sh
importer import_evaluations.sh
importer import_titres_alternatifs.sh
importer import_episodes.sh
importer import_participations.sh
importer import_credits_techniques.sh
importer import_oeuvres_connues.sh

duree=$((SECONDS - debut))

echo
echo "Durée totale des importations : $duree secondes"

# 9. Vérifier les 12 tables
echo "Vérification des données..."

docker compose exec -T db sh -s <<'VERIFY_DB'
set -eu

mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" cinema_next <<'SQL'
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'cinema_next'
ORDER BY TABLE_NAME;
SQL

# Vérifier que toutes les tables sont non vides.
mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" cinema_next <<'SQL'
SELECT
  (SELECT COUNT(*) FROM Oeuvre) AS oeuvres,
  (SELECT COUNT(*) FROM Personne) AS personnes,
  (SELECT COUNT(*) FROM Participation) AS participations,
  (SELECT COUNT(*) FROM CreditTechnique) AS credits,
  (SELECT COUNT(*) FROM OeuvreConnue) AS oeuvres_connues;
SQL
VERIFY_DB

echo
echo "======================================"
echo " IMPORTATION TERMINEE"
echo "======================================"
echo "Ancienne base : $BASE_ACTUELLE"
echo "Nouvelle base : $BASE_NOUVELLE"
echo
echo "IMPORTANT :"
echo "La base actuelle est conservée."
echo "Vérifie les données avant de basculer l'application."
echo "La bascule n'est pas automatique."
