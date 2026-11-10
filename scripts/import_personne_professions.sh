#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_import_common.sh"

echo "Importation : PersonneProfession"

awk_code='
NR > 1 && $5 != "\\N" {
  n = split($5, professions, ",")
  for (i = 1; i <= n; i++) {
    if (professions[i] != "")
      print $1 "\t" professions[i]
  }
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE PersonneProfession
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(nconst, nomProfession);
"

imdb_import "name.basics.tsv.gz" "$awk_code" "$sql"