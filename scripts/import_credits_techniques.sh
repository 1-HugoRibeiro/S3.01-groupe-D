
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/_import_common.sh"

echo "Importation : CreditTechnique"

awk_code='
BEGIN { OFS="\t" }
NR > 1 {
  if ($2 != "\\N" && $2 != "") {
    n = split($2, realisateurs, ",")
    for (i = 1; i <= n; i++) {
      print $1, realisateurs[i], "director"
    }
  }

  if ($3 != "\\N" && $3 != "") {
    n = split($3, scenaristes, ",")
    for (i = 1; i <= n; i++) {
      print $1, scenaristes[i], "writer"
    }
  }
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE CreditTechnique
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(tconst, nconst, role);
"

imdb_import "title.crew.tsv.gz" "$awk_code" "$sql"

echo "Terminé : CreditTechnique"