#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_import_common.sh"

echo "Importation : TitreAlternatif"

awk_code='
NR > 1 {
  print $1 "\t" $2 "\t" $3 "\t" $4 "\t" \
        $5 "\t" $6 "\t" $7 "\t" $8
}'

sql="
LOAD DATA LOCAL INFILE '__FILE__'
IGNORE INTO TABLE TitreAlternatif
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
ESCAPED BY ''
LINES TERMINATED BY '\n'
(@titleId, @ordering, @title, @region,
 @language, @types, @attributes, @isOriginalTitle)
SET
 titleId = @titleId,
 ordering = @ordering,
 title = @title,
 region = NULLIF(@region, CHAR(92,78)),
 language = NULLIF(@language, CHAR(92,78)),
 types = NULLIF(@types, CHAR(92,78)),
 attributes = NULLIF(@attributes, CHAR(92,78)),
 isOriginalTitle = NULLIF(@isOriginalTitle, CHAR(92,78));
"

imdb_import "title.akas.tsv.gz" "$awk_code" "$sql"