
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

imdb_import() {
  local fichier="$1"
  local programme_awk="$2"
  local requete_sql="$3"

  MSYS_NO_PATHCONV=1 docker compose exec -T \
    -e IMDB_DATABASE="${IMDB_DATABASE:-}" db \
    sh -s -- "$fichier" "$programme_awk" "$requete_sql" <<'DOCKER_SCRIPT'
set -eu

fichier="$1"
programme_awk="$2"
requete_sql="$3"

dossier="$(mktemp -d /tmp/imdb-import.XXXXXX)"
trap 'rm -rf "$dossier"' EXIT

export MARIADB_USER MARIADB_PASSWORD MARIADB_DATABASE

# Utilise la base actuelle par défaut,
# ou une autre base si IMDB_DATABASE est défini
export IMDB_DATABASE="${IMDB_DATABASE:-$MARIADB_DATABASE}"

export IMDB_LOT="$dossier/lot.tsv"
export IMDB_SQL="$(printf '%s' "$requete_sql" |
  sed "s|__FILE__|$IMDB_LOT|g")"

echo "Lecture de $fichier..."
echo "Base utilisée : $IMDB_DATABASE"

gzip -dc "/var/lib/mysql-files/$fichier" |
  awk -F '	' "$programme_awk" |
  split -l 20000 --filter='
    cat > "$IMDB_LOT"

    mariadb --local-infile=1 \
      -u"$MARIADB_USER" \
      -p"$MARIADB_PASSWORD" \
      "$IMDB_DATABASE" \
      -e "$IMDB_SQL" || exit 1

    rm -f "$IMDB_LOT"
    echo "Lot importé"
  ' -

echo "Importation terminée : $fichier"
DOCKER_SCRIPT
}
