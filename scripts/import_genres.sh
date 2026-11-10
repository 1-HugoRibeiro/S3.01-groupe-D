#!/usr/bin/env bash
set -euo pipefail

echo "Importation des genres IMDb..."

MSYS_NO_PATHCONV=1 docker compose exec -T db sh -c '
  set -eu

  gzip -dc /var/lib/mysql-files/title.basics.tsv.gz |
  awk -F "\t" '"'"'
    NR > 1 && $9 != "\\N" {
      n = split($9, genres, ",")
      for (i = 1; i <= n; i++)
        if (genres[i] != "") print genres[i]
    }
  '"'"' |
  sort -u |
  while IFS= read -r genre; do
    case "$genre" in
      ""|*[!a-zA-Z-]*)
        echo "Genre ignoré : $genre" >&2
        continue
        ;;
    esac

    mariadb \
      -u"$MARIADB_USER" \
      -p"$MARIADB_PASSWORD" \
      "$MARIADB_DATABASE" \
      -e "INSERT IGNORE INTO Genre (nomGenre) VALUES ('\''$genre'\'');"
  done
'

echo "Importation des genres terminée."