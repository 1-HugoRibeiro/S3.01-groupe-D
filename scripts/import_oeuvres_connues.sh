
#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/_import_common.sh"

echo "Importation : OeuvreConnue"

awk_code='
BEGIN { OFS="\t" }
NR > 1 && $6 != "\\N" && $6 != "" {
  n = split($6, oeuvres, ",")
  for (i = 1; i <= n; i++) {
    print $1, oeuvres[i]
  }
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE OeuvreConnue
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(nconst, tconst);
"

imdb_import "name.basics.tsv.gz" "$awk_code" "$sql"

echo "Terminé : OeuvreConnue"
