#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_import_common.sh"

echo "Importation : Evaluation"

awk_code='
NR > 1 {
  print $1 "\t" $2 "\t" $3
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE Evaluation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(tconst, averageRating, numVotes);
"

imdb_import "title.ratings.tsv.gz" "$awk_code" "$sql"