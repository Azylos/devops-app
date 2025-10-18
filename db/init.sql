-- Création de la table articles
CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    titre VARCHAR(255) NOT NULL,
    contenu TEXT NOT NULL,
    auteur VARCHAR(100) NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de données de test
INSERT INTO articles (titre, contenu, auteur, date) VALUES
    ('Introduction à FastAPI', 'FastAPI est un framework web moderne et rapide pour construire des APIs avec Python.', 'Jean Dupont', '2025-01-15'),
    ('Les bases de JavaScript', 'JavaScript est le langage de programmation du web, essentiel pour le développement frontend.', 'Marie Martin', '2025-01-16'),
    ('DevOps et CI/CD', 'Les pratiques DevOps permettent d''automatiser et d''améliorer le processus de développement logiciel.', 'Pierre Durand', '2025-01-17'),
    ('Docker pour les débutants', 'Docker permet de conteneuriser vos applications pour un déploiement simplifié.', 'Sophie Bernard', '2025-01-18'),
    ('PostgreSQL et les bases de données', 'PostgreSQL est un système de gestion de base de données relationnelle open source puissant.', 'Thomas Petit', '2025-01-19'),
    ('Kubernetes en production', 'Kubernetes orchestre vos conteneurs pour un déploiement scalable et résilient.', 'Laura Dubois', '2025-01-20')
ON CONFLICT DO NOTHING;

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_articles_date ON articles(date DESC);
CREATE INDEX IF NOT EXISTS idx_articles_auteur ON articles(auteur);
