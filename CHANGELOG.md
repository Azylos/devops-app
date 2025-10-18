# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère à [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### À venir
- Connexion du backend à PostgreSQL
- Opérations CRUD complètes (POST, PUT, DELETE)
- Authentification JWT
- Tests end-to-end (E2E)

---

## [1.0.0] - 2025-01-18

### 🎉 Première version stable

Cette version marque la première release complète de l'application DevOps avec toutes les fonctionnalités de base.

### Ajouté

#### Infrastructure
- Architecture Docker complète (backend, frontend, database)
- docker-compose.yml avec 3 services orchestrés
- Réseau Docker bridge pour la communication inter-services
- Volume persistant pour PostgreSQL
- Healthchecks pour tous les services
- Variables d'environnement avec .env.example

#### Backend (FastAPI)
- API REST avec FastAPI
- Route `GET /` pour le message de bienvenue
- Route `GET /articles` retournant une liste JSON d'articles
- Configuration CORS pour les requêtes cross-origin
- Documentation Swagger automatique sur `/docs`
- 4 articles de démonstration pré-chargés

#### Frontend (Node.js/Express)
- Serveur Express pour servir les fichiers statiques
- Interface web moderne HTML/CSS/JavaScript
- Récupération asynchrone des données avec fetch()
- Affichage dynamique des articles sous forme de cartes
- Gestion des erreurs de connexion à l'API
- Design responsive avec dégradé violet
- Bouton d'actualisation des articles

#### Base de données
- PostgreSQL 15 avec Alpine Linux
- Script d'initialisation automatique (init.sql)
- Table `articles` avec 6 articles de test
- Indexes pour améliorer les performances
- Support des connexions externes sur port 5432

#### CI/CD (GitHub Actions)
- Pipeline CI complet avec 5 jobs
- Tests unitaires automatisés (12 tests pytest)
- Linting du code Python avec flake8
- Build automatique des images Docker
- Tests d'intégration avec docker-compose
- Scan de sécurité avec Trivy
- Pipeline de release sur les tags
- Publication des images sur GitHub Container Registry
- Couverture de code à 100%

#### Tests
- **test_api.py** : 6 tests de validation de `/articles` (TP4)
  - Validation status_code == 200
  - Validation format JSON
  - Validation liste non vide
  - Validation structure des articles
  - Validation champs requis
- **test_main.py** : 7 tests complets de l'API (TP3)
  - Tests des routes / et /articles
  - Tests CORS
  - Validation unicité des IDs
  - Validation ordre des articles
- Total : **12 tests** avec 100% de couverture

#### Documentation
- README.md complet avec guide de démarrage
- CONTRIBUTING.md pour les contributeurs
- TP4-GUIDE.md pour la validation qualité
- .github/workflows/README.md pour le CI/CD
- .github/CI-CD-ARCHITECTURE.md pour l'architecture
- .github/TROUBLESHOOTING.md pour le dépannage
- TP-SUMMARY.md récapitulatif du projet

#### Outils de développement
- Makefile avec 30+ commandes utiles
- Script simulate_error.sh pour les tests
- Configuration pytest complète
- Configuration flake8 pour le linting
- .gitignore pour exclure les fichiers sensibles
- .dockerignore pour optimiser les builds

### Corrigé
- Problème de cache npm dans GitHub Actions (ajout de package-lock.json)
- Commande docker-compose → docker compose pour compatibilité V2
- Upload SARIF simplifié (format table au lieu de sarif)
- Permissions GitHub Actions pour le scan de sécurité

### Sécurité
- Scan automatique des vulnérabilités avec Trivy
- Linting automatique du code Python
- Validation des dépendances
- CORS configuré
- Aucune vulnérabilité critique détectée

---

## [0.2.0] - 2025-01-17 (TP3)

### Ajouté
- Tests unitaires complets avec pytest
- Workflow GitHub Actions CI/CD
- Scan de sécurité Trivy
- Linting avec flake8
- Pipeline de release automatique

---

## [0.1.0] - 2025-01-16 (TP2)

### Ajouté
- Infrastructure Docker initiale
- Backend FastAPI basique
- Frontend Node.js/Express
- Base de données PostgreSQL
- docker-compose.yml

---

## Types de changements

- **Ajouté** : pour les nouvelles fonctionnalités
- **Modifié** : pour les changements dans les fonctionnalités existantes
- **Déprécié** : pour les fonctionnalités bientôt supprimées
- **Supprimé** : pour les fonctionnalités supprimées
- **Corrigé** : pour les corrections de bugs
- **Sécurité** : en cas de vulnérabilités

---

## Conventions de versionnage

Ce projet suit [Semantic Versioning](https://semver.org/lang/fr/) :

- **MAJEUR** (X.0.0) : changements incompatibles avec les versions précédentes
- **MINEUR** (0.X.0) : ajout de fonctionnalités rétrocompatibles
- **PATCH** (0.0.X) : corrections de bugs rétrocompatibles

Exemples :
- `1.0.0` : Première version stable
- `1.1.0` : Ajout de fonctionnalités (ex: authentification)
- `1.1.1` : Correction de bugs
- `2.0.0` : Changements majeurs (ex: migration DB)

---

## Comment contribuer au CHANGELOG

Lors de l'ajout de nouvelles fonctionnalités :

1. Ajouter les changements dans la section `[Non publié]`
2. Classer les changements par catégorie (Ajouté, Modifié, etc.)
3. Lors de la release, déplacer vers une nouvelle version datée
4. Créer un tag Git correspondant à la version

Exemple de commit :
```bash
git add CHANGELOG.md
git commit -m "docs: mise à jour CHANGELOG pour v1.1.0"
git tag -a v1.1.0 -m "Release v1.1.0"
git push origin main --tags
```

---

## Liens

- [Repository GitHub](https://github.com/votre-username/devops-app)
- [Documentation complète](README.md)
- [Guide de contribution](CONTRIBUTING.md)
- [Issues](https://github.com/votre-username/devops-app/issues)
- [Releases](https://github.com/votre-username/devops-app/releases)
