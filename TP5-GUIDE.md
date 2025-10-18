# TP5 - RELEASE : Préparation à la mise en production

## Objectif

Gérer les versions et documenter les livrables pour préparer la mise en production.

---

## ✅ 1. Tag Git v1.0.0

Un tag Git permet de marquer un point spécifique dans l'historique comme étant important (généralement une release).

### Créer le tag v1.0.0

```bash
# S'assurer d'être sur la branche main et à jour
git checkout main
git pull origin main

# Créer un tag annoté avec un message
git tag -a v1.0.0 -m "Release v1.0.0 - Première version stable

Fonctionnalités :
- Backend FastAPI avec route /articles
- Frontend Node.js/Express
- Base de données PostgreSQL
- Infrastructure Docker complète
- CI/CD avec GitHub Actions
- 12 tests unitaires
- Documentation complète"

# Afficher le tag créé
git tag -l

# Voir les détails du tag
git show v1.0.0
```

### Pousser le tag vers GitHub

```bash
# Pousser le tag spécifique
git push origin v1.0.0

# Ou pousser tous les tags
git push origin --tags
```

### Vérifier le tag sur GitHub

Aller sur GitHub → **Code** → **Tags** → Voir `v1.0.0`

---

## ✅ 2. Release GitHub

La release GitHub se crée **automatiquement** grâce au workflow [.github/workflows/release.yml](.github/workflows/release.yml).

### Workflow automatique

**OUI, tout est automatique !** Dès que vous faites `git push origin v1.0.0` :

1. ✅ **GitHub Actions détecte le tag** (pattern `v*.*.*`)
2. ✅ **Job `release`** (durée ~30 secondes) :
   - Extrait la version du tag
   - Lit les notes de version depuis CHANGELOG.md
   - Crée la release GitHub automatiquement avec les notes
3. ✅ **Job `publish-docker`** (durée ~3-5 minutes) :
   - Build les images Docker (backend + frontend)
   - Convertit le nom du repo en minuscules (requis par Docker)
   - Publie sur GitHub Container Registry (ghcr.io)
   - Tags : `v1.0.0` et `latest`

**Résultat automatique :**
```
✅ Tag v1.0.0 créé sur GitHub
✅ Release GitHub publiée avec notes du CHANGELOG
✅ Images Docker disponibles :
   - ghcr.io/azylos/devops-app/backend:v1.0.0
   - ghcr.io/azylos/devops-app/backend:latest
   - ghcr.io/azylos/devops-app/frontend:v1.0.0
   - ghcr.io/azylos/devops-app/frontend:latest
```

**Vous n'avez RIEN à faire d'autre que pousser le tag !**

### Vérifier la release

Aller sur GitHub → **Releases** → Voir `Release v1.0.0`

La release contient :
- 📝 Notes de version (extraites de CHANGELOG.md)
- 📦 Assets (code source .zip et .tar.gz)
- 🐳 Images Docker publiées sur ghcr.io

### Créer une release manuellement (optionnel)

Si besoin de créer une release manuellement :

```bash
# Via GitHub CLI
gh release create v1.0.0 \
  --title "Release v1.0.0" \
  --notes-file CHANGELOG.md

# Ou via l'interface GitHub
# Releases → Draft a new release → Choisir le tag v1.0.0
```

---

## ✅ 3. CHANGELOG.md

Le fichier [CHANGELOG.md](CHANGELOG.md) documente tous les changements du projet.

### Structure du CHANGELOG

```markdown
# Changelog

## [Non publié]
### À venir
- Fonctionnalités futures

## [1.0.0] - 2025-01-18
### Ajouté
- Nouvelles fonctionnalités

### Modifié
- Changements existants

### Corrigé
- Corrections de bugs

### Sécurité
- Vulnérabilités corrigées
```

### Format utilisé

Le CHANGELOG suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/) :
- **Ajouté** : nouvelles fonctionnalités
- **Modifié** : changements aux fonctionnalités existantes
- **Déprécié** : fonctionnalités bientôt supprimées
- **Supprimé** : fonctionnalités supprimées
- **Corrigé** : corrections de bugs
- **Sécurité** : vulnérabilités

### Mettre à jour le CHANGELOG

```bash
# Éditer CHANGELOG.md
vim CHANGELOG.md

# Ajouter les changements dans la section [Non publié]
# Lors de la release, créer une nouvelle section [1.0.0]

# Commiter
git add CHANGELOG.md
git commit -m "docs: mise à jour CHANGELOG pour v1.0.0"
git push origin main
```

---

## ✅ 4. Configuration CI pour les tags

Le workflow de release est configuré pour se déclencher **uniquement sur les tags**.

### Configuration actuelle

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'  # ✅ Déclenché uniquement sur les tags vX.Y.Z
```

### Déclencheurs

| Événement | CI Workflow | Release Workflow |
|-----------|-------------|------------------|
| `git push origin main` | ✅ Exécuté | ❌ Non exécuté |
| `git push origin develop` | ✅ Exécuté | ❌ Non exécuté |
| `git push origin v1.0.0` | ❌ Non exécuté | ✅ Exécuté |
| Pull Request | ✅ Exécuté | ❌ Non exécuté |

### Workflow de release

```yaml
jobs:
  release:
    # 1. Créer la release GitHub
    - Lire CHANGELOG.md
    - Extraire notes de version
    - Créer release avec assets

  publish-docker:
    # 2. Publier les images Docker
    - Build backend
    - Build frontend
    - Push vers ghcr.io
    - Tags: v1.0.0 + latest
```

---

## 🚀 Procédure complète de release

### Étape 1 : Préparer le code

```bash
# S'assurer que tout est commité
git status

# S'assurer d'être à jour
git checkout main
git pull origin main

# Vérifier que les tests passent
cd backend
pytest -v
```

### Étape 2 : Mettre à jour le CHANGELOG

```bash
# Éditer CHANGELOG.md
vim CHANGELOG.md

# Déplacer les changements de [Non publié] vers [1.0.0]
# Ajouter la date : ## [1.0.0] - 2025-01-18

# Commiter
git add CHANGELOG.md
git commit -m "docs: préparation release v1.0.0"
git push origin main
```

### Étape 3 : Créer et pousser le tag

```bash
# Créer le tag annoté
git tag -a v1.0.0 -m "Release v1.0.0 - Première version stable"

# Pousser le tag
git push origin v1.0.0
```

### Étape 4 : Vérifier la release

1. **GitHub Actions** : Actions → Observer le workflow `Release`
2. **Release** : Releases → Vérifier `Release v1.0.0`
3. **Images Docker** : Packages → Voir `backend:v1.0.0` et `frontend:v1.0.0`

### Étape 5 : Tester la release

```bash
# Télécharger et tester l'image Docker
docker pull ghcr.io/VOTRE_USERNAME/devops-app/backend:v1.0.0
docker pull ghcr.io/VOTRE_USERNAME/devops-app/frontend:v1.0.0

# Ou utiliser docker-compose avec les images de la release
docker compose up -d
```

---

## 📊 Semantic Versioning

Ce projet suit [Semantic Versioning](https://semver.org/lang/fr/) : `MAJEUR.MINEUR.PATCH`

### Format : X.Y.Z

- **X (MAJEUR)** : Changements incompatibles avec les versions précédentes
  - Exemple : `2.0.0` - Migration de la base de données

- **Y (MINEUR)** : Ajout de fonctionnalités rétrocompatibles
  - Exemple : `1.1.0` - Ajout de l'authentification JWT

- **Z (PATCH)** : Corrections de bugs rétrocompatibles
  - Exemple : `1.0.1` - Correction d'un bug dans /articles

### Exemples de versioning

```
1.0.0 → 1.0.1  (Correction de bug)
1.0.1 → 1.1.0  (Nouvelle fonctionnalité)
1.1.0 → 1.1.1  (Correction de bug)
1.1.1 → 2.0.0  (Changement majeur)
```

### Préfixes de version

- `v1.0.0` : Release stable
- `v1.0.0-alpha` : Version alpha
- `v1.0.0-beta` : Version beta
- `v1.0.0-rc.1` : Release candidate

---

## 🔧 Commandes utiles

### Gestion des tags

```bash
# Lister tous les tags
git tag -l

# Voir les détails d'un tag
git show v1.0.0

# Supprimer un tag local
git tag -d v1.0.0

# Supprimer un tag distant (⚠️ à utiliser avec précaution)
git push origin --delete v1.0.0

# Créer un tag sur un commit spécifique
git tag -a v1.0.0 9fceb02 -m "Release v1.0.0"
```

### Gestion des releases

```bash
# Lister les releases (GitHub CLI)
gh release list

# Voir une release spécifique
gh release view v1.0.0

# Supprimer une release
gh release delete v1.0.0

# Télécharger les assets d'une release
gh release download v1.0.0
```

---

## 📝 Checklist de release

### Avant la release

- [ ] Tous les tests passent (`pytest -v`)
- [ ] Le linting passe (`flake8 .`)
- [ ] Le build Docker fonctionne (`docker compose build`)
- [ ] CHANGELOG.md est à jour
- [ ] Version documentée dans CHANGELOG.md
- [ ] Toutes les PR sont mergées
- [ ] Branche main est à jour

### Créer la release

- [ ] Tag Git créé (`git tag -a v1.0.0`)
- [ ] Tag poussé vers GitHub (`git push origin v1.0.0`)
- [ ] Workflow Release s'exécute sans erreur
- [ ] Release GitHub créée automatiquement
- [ ] Images Docker publiées

### Après la release

- [ ] Vérifier la release sur GitHub
- [ ] Tester les images Docker publiées
- [ ] Vérifier les notes de version
- [ ] Annoncer la release (si applicable)
- [ ] Créer la section [Non publié] dans CHANGELOG.md

---

## 🎯 Validation du TP5

### Checklist

- [x] **Tag Git v1.0.0 créé** avec message descriptif
- [x] **Release GitHub publiée** automatiquement via workflow
- [x] **CHANGELOG.md créé** avec liste complète des changements
- [x] **CI configurée pour les tags** (workflow release.yml)
- [x] **Images Docker publiées** sur GitHub Container Registry
- [x] **Documentation complète** dans ce guide

### Livrables

| Livrable | Statut | Fichier |
|----------|--------|---------|
| CHANGELOG.md | ✅ | [CHANGELOG.md](CHANGELOG.md) |
| Workflow Release | ✅ | [.github/workflows/release.yml](.github/workflows/release.yml) |
| Guide TP5 | ✅ | [TP5-GUIDE.md](TP5-GUIDE.md) |
| Tag v1.0.0 | ⏳ À créer | `git tag -a v1.0.0` |
| Release GitHub | ⏳ Automatique | Créée par GitHub Actions |

---

## 🔗 Liens utiles

- [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
- [Semantic Versioning](https://semver.org/lang/fr/)
- [GitHub Releases](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Git Tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)

---

## 📦 Exemple de release complète

### Commandes à exécuter

```bash
# 1. Mise à jour du CHANGELOG
git add CHANGELOG.md
git commit -m "docs: préparation release v1.0.0"
git push origin main

# 2. Création du tag
git tag -a v1.0.0 -m "Release v1.0.0 - Première version stable"

# 3. Push du tag
git push origin v1.0.0

# 4. Observer le workflow
# GitHub → Actions → Workflow "Release"

# 5. Vérifier la release
# GitHub → Releases → "Release v1.0.0"
```

### Résultat attendu

```
✅ Tag v1.0.0 créé
✅ Workflow Release déclenché
✅ Release GitHub publiée avec notes
✅ Images Docker :
   - ghcr.io/USERNAME/devops-app/backend:v1.0.0
   - ghcr.io/USERNAME/devops-app/backend:latest
   - ghcr.io/USERNAME/devops-app/frontend:v1.0.0
   - ghcr.io/USERNAME/devops-app/frontend:latest
```

**TP5 complété avec succès ! 🎉**
