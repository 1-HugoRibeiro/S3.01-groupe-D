#!/bin/bash
set -euo pipefail

source scripts/_import_common.sh

echo "Importation des personnes IMDb..."
debut=$(date +%s)

imdb_load "name.basics.tsv.gz" "
LOAD DATA LOCAL INFILE '/dev/stdin'
INTO TABLE Personne
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@nconst, @primaryName, @birthYear, @deathYear,
 @primaryProfession, @knownForTitles)
SET
 nconst = @nconst,
 primaryName = @primaryName,
 birthYear = NULLIF(@birthYear, '\\\\N'),
 deathYear = NULLIF(@deathYear, '\\\\N');
"

fin=$(date +%s)
echo "Personnes importées en $((fin - debut)) secondes."