# TP5 – RELEASE : Préparation à la mise en production

## 📋 Objectif

Gérer les versions et documenter les livrables pour préparer une release production.

---

## 📝 Consignes

### 1. Créer un tag Git v1.0.0

**Comprendre le versioning sémantique :**

Format : `MAJEUR.MINEUR.PATCH`
- **MAJEUR** : changements incompatibles (breaking changes)
- **MINEUR** : nouvelles fonctionnalités rétrocompatibles
- **PATCH** : corrections de bugs

**Créer le tag :**
```bash
# S'assurer d'être sur main et à jour
git checkout main
git pull origin main

# Créer un tag annoté
git tag -a v1.0.0 -m "Release v1.0.0 - Première version stable

Fonctionnalités :
- Backend FastAPI avec route /articles
- Frontend Node.js/Express
- Base de données PostgreSQL
- Infrastructure Docker complète
- CI/CD avec GitHub Actions
- 12 tests unitaires
- Documentation complète"

# Voir le tag créé
git tag -l
git show v1.0.0
```

**Pousser le tag :**
```bash
# Pousser le tag spécifique
git push origin v1.0.0

# Ou pousser tous les tags
git push origin --tags
```

### 2. Publier une release GitHub

La release se crée **automatiquement** via GitHub Actions !

**Workflow automatique :**

Quand vous poussez un tag `v*.*.*`, le fichier `.github/workflows/release.yml` :

1. **Détecte le tag**
2. **Lit CHANGELOG.md** pour extraire les notes
3. **Crée la release GitHub** automatiquement
4. **Build et publie les images Docker** sur DockerHub

**Vérifier la release :**
```bash
# Aller sur GitHub
# Repository → Releases → Voir "Release v1.0.0"
```

**Ou créer manuellement (optionnel) :**
```bash
# Via GitHub CLI
gh release create v1.0.0 \
  --title "Release v1.0.0" \
  --notes "Première version stable de l'application DevOps"

# Ou via l'interface GitHub
# Releases → Draft a new release → Choisir tag v1.0.0
```

### 3. Ajouter CHANGELOG.md

**Créer `CHANGELOG.md` à la racine :**

```markdown
# Changelog

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)

## [1.0.0] - 2025-01-18

### Ajouté

#### Infrastructure
- Architecture Docker complète (backend, frontend, database)
- docker-compose.yml avec 3 services
- Réseau Docker bridge
- Volume persistant PostgreSQL
- Healthchecks pour tous les services

#### Backend (FastAPI)
- Route GET / pour message de bienvenue
- Route GET /articles retournant liste JSON
- Configuration CORS
- Documentation Swagger sur /docs
- 4 articles de démonstration

#### Frontend (Node.js/Express)
- Serveur Express
- Interface web HTML/CSS/JavaScript
- Fetch asynchrone des articles
- Design responsive
- Gestion des erreurs

#### Base de données
- PostgreSQL 15
- Script d'initialisation (init.sql)
- 6 articles de test
- Indexes de performance

#### CI/CD
- Pipeline CI complet (5 jobs)
- Tests unitaires (12 tests pytest)
- Linting flake8
- Build Docker automatique
- Tests d'intégration
- Scan sécurité Trivy
- Pipeline de release sur tags
- Publication DockerHub

### Sécurité
- Scan automatique Trivy
- Aucune vulnérabilité critique

## [0.1.0] - 2025-01-16

### Ajouté
- Structure initiale du projet
- Backend FastAPI basique
- Frontend HTML simple
```

**Commiter le CHANGELOG :**
```bash
git add CHANGELOG.md
git commit -m "docs: ajout CHANGELOG v1.0.0"
git push origin main
```

### 4. Configurer CI pour les tags uniquement

**Vérifier `.github/workflows/release.yml` :**

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'   # ✅ Se déclenche UNIQUEMENT sur les tags

jobs:
  release:
    name: Create Release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Extract version
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT

      - name: Read CHANGELOG
        run: |
          VERSION="${{ steps.version.outputs.VERSION }}"
          awk "/## \[${VERSION#v}\]/,/## \[/{print}" CHANGELOG.md > notes.md

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          name: Release ${{ steps.version.outputs.VERSION }}
          body_path: notes.md
```

**Comportement :**

| Action | CI Workflow | Release Workflow |
|--------|-------------|------------------|
| `git push origin main` | ✅ S'exécute | ❌ Ne s'exécute PAS |
| `git push origin v1.0.0` | ❌ Ne s'exécute PAS | ✅ S'exécute |

---

## ✅ Livrable

**Lien vers la release GitHub contenant :**

✅ Tag Git v1.0.0 visible
✅ Release GitHub publiée
✅ Notes de version (depuis CHANGELOG.md)
✅ Assets (source code .zip et .tar.gz)
✅ Images Docker publiées (si DockerHub configuré)

**Exemple :**
https://github.com/votreusername/devops-app/releases/tag/v1.0.0

---

## 🎯 Critères de validation

- [ ] Tag v1.0.0 créé avec `git tag -a`
- [ ] Tag poussé sur GitHub
- [ ] CHANGELOG.md présent avec version 1.0.0
- [ ] Release GitHub créée (auto ou manuelle)
- [ ] Notes de version dans la release
- [ ] Workflow release.yml se déclenche sur tags uniquement
- [ ] Images Docker publiées (optionnel)

---

## 🔄 Workflow complet de release

```
Developer
    ↓
1. Mettre à jour CHANGELOG.md
    ↓
git commit -m "docs: préparation v1.0.0"
git push origin main
    ↓
2. Créer le tag
    ↓
git tag -a v1.0.0 -m "Release v1.0.0"
    ↓
3. Pousser le tag
    ↓
git push origin v1.0.0
    ↓
GitHub Actions (release.yml)
    ↓
  ✅ Extrait version
  ✅ Lit CHANGELOG
  ✅ Crée release
  ✅ Build Docker
  ✅ Publie images
    ↓
Release disponible !
  📦 GitHub Releases
  🐳 DockerHub (optionnel)
```

---

## 📦 Utiliser la release

**Télécharger le code source :**
```bash
# Via wget
wget https://github.com/votreusername/devops-app/archive/refs/tags/v1.0.0.tar.gz

# Via git clone
git clone --branch v1.0.0 https://github.com/votreusername/devops-app.git
```

**Utiliser les images Docker (si publiées) :**
```bash
docker pull votreusername/devops-app-backend:v1.0.0
docker pull votreusername/devops-app-frontend:v1.0.0
```

---

## 🛠️ Script d'aide

**Créer `create-release.sh` :**
```bash
#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

# Ajouter 'v' si absent
if [[ ! $VERSION =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo "🚀 Creating release $VERSION"

# Vérifier CHANGELOG
if ! grep -q "\[${VERSION#v}\]" CHANGELOG.md; then
    echo "⚠️  Version not in CHANGELOG.md"
    exit 1
fi

# Créer le tag
git tag -a "$VERSION" -m "Release $VERSION"

# Pousser
read -p "Push tag $VERSION? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin "$VERSION"
    echo "✅ Release $VERSION created!"
fi
```

**Utilisation :**
```bash
chmod +x create-release.sh
./create-release.sh 1.0.0
```

---

## 📊 Versions futures

**Exemples de versioning :**

```
v1.0.0 → v1.0.1  (Correction de bug)
v1.0.1 → v1.1.0  (Nouvelle fonctionnalité)
v1.1.0 → v1.1.1  (Correction)
v1.1.1 → v2.0.0  (Breaking change)
```

**Préfixes de version :**
- `v1.0.0` - Version stable
- `v1.0.0-alpha` - Version alpha
- `v1.0.0-beta` - Version beta
- `v1.0.0-rc.1` - Release candidate

---

## 📚 Ressources

- [Semantic Versioning](https://semver.org/lang/fr/)
- [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Git Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)

**TP5 complété ! 🎉**
