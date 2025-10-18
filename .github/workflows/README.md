# Workflows GitHub Actions

Ce dossier contient les workflows d'intégration et de déploiement continus (CI/CD) pour le projet DevOps App.

## Workflows disponibles

### 1. CI Pipeline (`ci.yml`)

Pipeline d'intégration continue qui s'exécute sur chaque push et pull request.

#### Jobs

1. **test-backend** - Tests du backend FastAPI
   - Installation de Python 3.11
   - Installation des dépendances
   - Exécution des tests avec pytest
   - Génération du rapport de couverture

2. **lint-backend** - Analyse statique du code Python
   - Linting avec flake8
   - Détection des erreurs de syntaxe
   - Vérification de la qualité du code

3. **test-frontend** - Tests du frontend Node.js
   - Installation de Node.js 18
   - Installation des dépendances npm
   - Vérification de la syntaxe JavaScript

4. **build-docker** - Construction des images Docker
   - Build des images backend et frontend
   - Utilisation du cache pour optimiser les builds
   - Test de construction réussi

5. **integration-test** - Tests d'intégration
   - Démarrage de tous les services avec docker-compose
   - Tests de santé (health checks)
   - Vérification de la communication entre services
   - Test de l'API et de la base de données

6. **security-scan** - Analyse de sécurité
   - Scan des vulnérabilités avec Trivy
   - Upload des résultats dans GitHub Security

#### Déclenchement

```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
```

### 2. Release Pipeline (`release.yml`)

Pipeline de release qui publie les images Docker sur les tags de version.

#### Jobs

1. **release** - Création de la release GitHub
   - Création automatique d'une release sur GitHub

2. **publish-docker** - Publication des images Docker
   - Build et push vers GitHub Container Registry
   - Tags `latest` et version spécifique

#### Déclenchement

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

#### Utilisation

```bash
# Créer un tag et le pousser
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

## Variables d'environnement

Les workflows utilisent les variables suivantes :

- `REGISTRY`: GitHub Container Registry (`ghcr.io`)
- `BACKEND_IMAGE_NAME`: Nom de l'image backend
- `FRONTEND_IMAGE_NAME`: Nom de l'image frontend

## Secrets requis

- `GITHUB_TOKEN`: Fourni automatiquement par GitHub Actions

## Badges de statut

Ajoutez ces badges à votre README principal :

```markdown
![CI/CD Pipeline](https://github.com/USERNAME/REPO/actions/workflows/ci.yml/badge.svg)
![Release](https://github.com/USERNAME/REPO/actions/workflows/release.yml/badge.svg)
```

## Optimisations

- **Cache des dépendances** : pip et npm utilisent le cache GitHub Actions
- **Cache Docker** : Les layers Docker sont mis en cache
- **Builds parallèles** : Backend et frontend construits en parallèle
- **Tests conditionnels** : Les builds ne se lancent que si les tests passent

## Dépannage

### Les tests échouent

```bash
# Lancer les tests localement
cd backend
pytest -v
```

### Le build Docker échoue

```bash
# Tester localement
docker build -t test-backend ./backend
docker build -t test-frontend ./frontend
```

### Les tests d'intégration échouent

```bash
# Tester localement avec docker-compose
docker-compose up -d --build
docker-compose ps
docker-compose logs
```

## Améliorations futures

- [ ] Ajout de tests end-to-end (E2E)
- [ ] Déploiement automatique sur un environnement de staging
- [ ] Notifications Slack/Discord
- [ ] Analyse de performance
- [ ] Tests de charge
