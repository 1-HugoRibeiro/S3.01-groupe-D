
#!/usr/bin/env bash
set -euo pipefail

# On se place à la racine du projet
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT_DIR/database/imports"

mkdir -p "$DEST"

# Les sept fichiers fournis par IMDb
FILES=(
    "title.basics"
    "title.akas"
    "name.basics"
    "title.crew"
    "title.episode"
    "title.principals"
    "title.ratings"
)

BASE_URL="https://datasets.imdbws.com"

echo "Téléchargement des données IMDb..."
START=$(date +%s)

for FILE in "${FILES[@]}"; do
    echo "Téléchargement de $FILE..."

    curl --fail --location --retry 3 \
        --output "$DEST/$FILE.tsv.gz.tmp" \
        "$BASE_URL/$FILE.tsv.gz"

    # On remplace l'ancien fichier seulement
    # si le téléchargement a réussi
    mv "$DEST/$FILE.tsv.gz.tmp" "$DEST/$FILE.tsv.gz"
done

END=$(date +%s)

echo "Téléchargement terminé."
echo "Durée totale : $((END - START)) secondes"
