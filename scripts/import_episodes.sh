#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_import_common.sh"

echo "Importation : Episode"

awk_code='
NR > 1 {
  print $1 "\t" $2 "\t" $3 "\t" $4
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE Episode
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(@tconst, @parentTconst, @seasonNumber, @episodeNumber)
SET
 tconst = @tconst,
 parentTconst = @parentTconst,
 seasonNumber = NULLIF(@seasonNumber, CHAR(92,78)),
 episodeNumber = NULLIF(@episodeNumber, CHAR(92,78));
"

imdb_import "title.episode.tsv.gz" "$awk_code" "$sql"