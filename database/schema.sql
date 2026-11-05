-- Tables principales : les œuvres et les personnes
CREATE TABLE Oeuvre (
    tconst VARCHAR(12) NOT NULL,
    titleType VARCHAR(30) NOT NULL,
    primaryTitle TEXT NOT NULL,
    originalTitle TEXT,
    isAdult BOOLEAN,
    startYear SMALLINT UNSIGNED,
    endYear SMALLINT UNSIGNED,
    runtimeMinutes INT UNSIGNED,
    PRIMARY KEY (tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Personne (
    nconst VARCHAR(12) NOT NULL,
    primaryName VARCHAR(255) NOT NULL,
    birthYear SMALLINT UNSIGNED,
    deathYear SMALLINT UNSIGNED,
    PRIMARY KEY (nconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- On sépare les genres et les professions pour éviter
-- de stocker plusieurs valeurs dans une même colonne
CREATE TABLE Genre (
    nomGenre VARCHAR(80) NOT NULL,
    PRIMARY KEY (nomGenre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Profession (
    nomProfession VARCHAR(100) NOT NULL,
    PRIMARY KEY (nomProfession)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Les différents titres d'une œuvre selon les pays
CREATE TABLE TitreAlternatif (
    titleId VARCHAR(12) NOT NULL,
    ordering INT UNSIGNED NOT NULL,
    title TEXT NOT NULL,
    region VARCHAR(20),
    language VARCHAR(20),
    types VARCHAR(255),
    attributes TEXT,
    isOriginalTitle BOOLEAN,
    PRIMARY KEY (titleId, ordering),
    CONSTRAINT fk_aka_oeuvre
        FOREIGN KEY (titleId) REFERENCES Oeuvre(tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Les notes IMDb des œuvres
CREATE TABLE Evaluation (
    tconst VARCHAR(12) NOT NULL,
    averageRating DECIMAL(3,1) NOT NULL,
    numVotes INT UNSIGNED NOT NULL,
    PRIMARY KEY (tconst),
    CONSTRAINT fk_evaluation_oeuvre
        FOREIGN KEY (tconst) REFERENCES Oeuvre(tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Chaque épisode est relié à sa série avec parentTconst
CREATE TABLE Episode (
    tconst VARCHAR(12) NOT NULL,
    parentTconst VARCHAR(12) NOT NULL,
    seasonNumber INT UNSIGNED,
    episodeNumber INT UNSIGNED,
    PRIMARY KEY (tconst),
    KEY idx_episode_parent (parentTconst),
    CONSTRAINT fk_episode_oeuvre
        FOREIGN KEY (tconst) REFERENCES Oeuvre(tconst),
    CONSTRAINT fk_episode_parent
        FOREIGN KEY (parentTconst) REFERENCES Oeuvre(tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Les personnes qui participent aux films et séries
-- ordering permet de distinguer les participations d'une même œuvre
CREATE TABLE Participation (
    tconst VARCHAR(12) NOT NULL,
    ordering INT UNSIGNED NOT NULL,
    nconst VARCHAR(12) NOT NULL,
    category VARCHAR(80) NOT NULL,
    job TEXT,
    `characters` TEXT,
    PRIMARY KEY (tconst, ordering),
    KEY idx_participation_personne (nconst),
    CONSTRAINT fk_participation_oeuvre
        FOREIGN KEY (tconst) REFERENCES Oeuvre(tconst),
    CONSTRAINT fk_participation_personne
        FOREIGN KEY (nconst) REFERENCES Personne(nconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Une œuvre peut avoir plusieurs genres
CREATE TABLE OeuvreGenre (
    tconst VARCHAR(12) NOT NULL,
    nomGenre VARCHAR(80) NOT NULL,
    PRIMARY KEY (tconst, nomGenre),
    CONSTRAINT fk_oeuvregenre_oeuvre
        FOREIGN KEY (tconst) REFERENCES Oeuvre(tconst),
    CONSTRAINT fk_oeuvregenre_genre
        FOREIGN KEY (nomGenre) REFERENCES Genre(nomGenre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Une personne peut exercer plusieurs professions
CREATE TABLE PersonneProfession (
    nconst VARCHAR(12) NOT NULL,
    nomProfession VARCHAR(100) NOT NULL,
    PRIMARY KEY (nconst, nomProfession),
    CONSTRAINT fk_personneprofession_personne
        FOREIGN KEY (nconst) REFERENCES Personne(nconst),
    CONSTRAINT fk_personneprofession_profession
        FOREIGN KEY (nomProfession) REFERENCES Profession(nomProfession)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Réalisateurs et scénaristes récupérés depuis title.crew
CREATE TABLE CreditTechnique (
    tconst VARCHAR(12) NOT NULL,
    nconst VARCHAR(12) NOT NULL,
    role VARCHAR(20) NOT NULL,
    PRIMARY KEY (tconst, nconst, role),
    KEY idx_credit_personne (nconst),
    CONSTRAINT fk_credit_oeuvre
        FOREIGN KEY (tconst) REFERENCES Oeuvre(tconst),
    CONSTRAINT fk_credit_personne
        FOREIGN KEY (nconst) REFERENCES Personne(nconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Les œuvres pour lesquelles une personne est connue
-- Ces informations viennent de knownForTitles dans name.basics
CREATE TABLE OeuvreConnue (
    nconst VARCHAR(12) NOT NULL,
    tconst VARCHAR(12) NOT NULL,
    PRIMARY KEY (nconst, tconst),
    KEY idx_connue_oeuvre (tconst),
    CONSTRAINT fk_connue_personne
        FOREIGN KEY (nconst) REFERENCES Personne(nconst),
    CONSTRAINT fk_connue_oeuvre
        FOREIGN KEY (tconst) REFERENCES Oeuvre(tconst)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
