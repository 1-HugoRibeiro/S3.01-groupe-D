#!/bin/bash
set -euo pipefail

source scripts/_import_common.sh

echo "Importation des œuvres IMDb..."
debut=$(date +%s)

imdb_load "title.basics.tsv.gz" "
LOAD DATA LOCAL INFILE '/dev/stdin'
INTO TABLE Oeuvre
CHARACTER SET utf8mb4
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@tconst, @titleType, @primaryTitle, @originalTitle,
 @isAdult, @startYear, @endYear, @runtimeMinutes, @genres)
SET
 tconst = @tconst,
 titleType = @titleType,
 primaryTitle = @primaryTitle,
 originalTitle = NULLIF(@originalTitle, '\\\\N'),
 isAdult = NULLIF(@isAdult, '\\\\N'),
 startYear = NULLIF(@startYear, '\\\\N'),
 endYear = NULLIF(@endYear, '\\\\N'),
 runtimeMinutes = NULLIF(@runtimeMinutes, '\\\\N');
"

fin=$(date +%s)
echo "Œuvres importées en $((fin - debut)) secondes."