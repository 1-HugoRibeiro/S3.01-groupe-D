
#!/usr/bin/env bash
set -euo pipefail

echo "Importation des professions IMDb..."

MSYS_NO_PATHCONV=1 docker compose exec -T db sh -c '
  set -eu

  gzip -dc /var/lib/mysql-files/name.basics.tsv.gz |
  awk -F "\t" '"'"'
    NR > 1 && $5 != "\\N" {
      n = split($5, professions, ",")
      for (i = 1; i <= n; i++)
        if (professions[i] != "") print professions[i]
    }
  '"'"' |
  sort -u |
  while IFS= read -r profession; do
    case "$profession" in
      ""|*[!a-zA-Z0-9_-]*)
        echo "Profession ignorée : $profession" >&2
        continue
        ;;
    esac

    mariadb \
      -u"$MARIADB_USER" \
      -p"$MARIADB_PASSWORD" \
      "$MARIADB_DATABASE" \
      -e "INSERT IGNORE INTO Profession (nomProfession) VALUES ('\''$profession'\'');"
  done
'

echo "Importation des professions terminée."
