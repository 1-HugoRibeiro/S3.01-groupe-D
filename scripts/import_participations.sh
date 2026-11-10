#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_import_common.sh"

echo "Importation : Participation"

awk_code='
NR > 1 {
  print $1 "\t" $2 "\t" $3 "\t" \
        $4 "\t" $5 "\t" $6
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE Participation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(@tconst, @ordering, @nconst, @category,
 @job, @characters)
SET
 tconst = @tconst,
 ordering = @ordering,
 nconst = @nconst,
 category = @category,
 job = NULLIF(@job, CHAR(92,78)),
 \`characters\` = NULLIF(@characters, CHAR(92,78));
"

imdb_import "title.principals.tsv.gz" "$awk_code" "$sql"