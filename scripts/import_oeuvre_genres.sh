#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_import_common.sh"

echo "Importation : OeuvreGenre"

awk_code='
NR > 1 && $9 != "\\N" {
  n = split($9, genres, ",")
  for (i = 1; i <= n; i++) {
    if (genres[i] != "")
      print $1 "\t" genres[i]
  }
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE OeuvreGenre
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(tconst, nomGenre);
"

imdb_import "title.basics.tsv.gz" "$awk_code" "$sql"