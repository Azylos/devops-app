# 📚 Documentation des TPs DevOps

Ce dossier contient les résumés et directives de tous les travaux pratiques (TP) du projet DevOps.

---

## 📋 Vue d'ensemble des TPs

| TP | Titre | Objectif | Statut |
|----|-------|----------|--------|
| **TP2** | CODE : Développement collaboratif | Mettre en place le code source versionné | ✅ |
| **TP3** | BUILD : Intégration continue | Automatiser la construction avec Docker | ✅ |
| **TP4** | TEST : Validation de la qualité | Automatiser les tests dans la CI | ✅ |
| **TP5** | RELEASE : Mise en production | Gérer les versions et releases | ✅ |
| **TP6** | DEPLOY : Déploiement automatisé | Déployer sur un environnement distant | ✅ |

---

## 📖 Résumés des TPs

### [TP2 - CODE : Développement collaboratif](./TP2-CODE.md)

**Objectif :** Mettre en place le code source versionné de l'application.

**Livrables :**
- Repository GitHub public `devops-app`
- Structure frontend/backend/db
- API FastAPI avec route `/articles`
- Page HTML/JS avec `fetch()`
- Commits avec messages clairs

**Technologies :** Git, GitHub, FastAPI, JavaScript

---

### [TP3 - BUILD : Intégration continue & conteneurisation](./TP3-BUILD.md)

**Objectif :** Automatiser la construction et la vérification du projet.

**Livrables :**
- Dockerfile backend (FastAPI)
- Dockerfile frontend (Node.js)
- docker-compose.yml avec 3 services
- GitHub Actions CI (build + tests)
- Tests unitaires pytest

**Technologies :** Docker, Docker Compose, GitHub Actions, Pytest

---

### [TP4 - TEST : Validation de la qualité](./TP4-TEST.md)

**Objectif :** Automatiser les tests de l'application dans la CI.

**Livrables :**
- Fichier `test_api.py` avec pytest
- Test vérifiant `status_code == 200`
- Tests dans GitHub Actions
- Simulation d'erreur et correction
- Captures d'écran pipeline vert/rouge

**Technologies :** Pytest, FastAPI TestClient, GitHub Actions

---

### [TP5 - RELEASE : Préparation à la mise en production](./TP5-RELEASE.md)

**Objectif :** Gérer les versions et documenter les livrables.

**Livrables :**
- Tag Git `v1.0.0`
- Release GitHub publiée
- Fichier `CHANGELOG.md`
- CI déclenchée uniquement sur tags
- Images Docker publiées

**Technologies :** Git Tags, GitHub Releases, Semantic Versioning, CHANGELOG

---

### [TP6 - DEPLOY : Déploiement automatisé](./TP6-DEPLOY.md)

**Objectif :** Déployer automatiquement la release sur un environnement distant.

**Livrables :**
- Compte sur Render/Railway/Fly.io
- Images Docker sur DockerHub
- Application accessible publiquement
- Pipeline de déploiement automatique
- Lien vers l'application en ligne

**Technologies :** DockerHub, Render, GitHub Actions, API Deployment

---

## 🎯 Progression du projet

```
TP2: CODE
  ↓ Repository GitHub + Code source

TP3: BUILD
  ↓ Docker + CI/CD

TP4: TEST
  ↓ Tests automatisés

TP5: RELEASE
  ↓ Versioning + Release

TP6: DEPLOY
  ↓ Application en production

✅ PROJET COMPLET
```

---

## 📁 Structure complète du projet

```
devops-app/
├── docs/                    # 📚 Documentation TPs
│   ├── README.md           # Ce fichier
│   ├── TP2-CODE.md         # TP2 : Développement collaboratif
│   ├── TP3-BUILD.md        # TP3 : Intégration continue
│   ├── TP4-TEST.md         # TP4 : Validation qualité
│   ├── TP5-RELEASE.md      # TP5 : Mise en production
│   └── TP6-DEPLOY.md       # TP6 : Déploiement automatisé
├── backend/                 # API FastAPI
│   ├── main.py
│   ├── test_api.py
│   ├── test_main.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/                # Application Node.js
│   ├── server.js
│   ├── public/index.html
│   ├── package.json
│   └── Dockerfile
├── db/                      # Base de données
│   └── init.sql
├── .github/workflows/       # CI/CD
│   ├── ci.yml
│   └── release.yml
├── docker-compose.yml       # Orchestration
├── CHANGELOG.md            # Historique versions
└── README.md               # Documentation principale
```

---

## 🚀 Démarrage rapide

### Développement local

```bash
# Backend
cd backend
pip install -r requirements.txt
uvicorn main:app --reload

# Frontend
cd frontend
npm install
npm start
```

### Avec Docker

```bash
# Démarrer tous les services
docker-compose up -d --build

# Arrêter
docker-compose down
```

### Tests

```bash
# Tests backend
cd backend
pytest -v

# CI local
make ci
```

### Release

```bash
# Créer une release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

---

## 📊 Métriques du projet

| Métrique | Valeur |
|----------|--------|
| Tests unitaires | 12 |
| Code coverage | 100% |
| Services Docker | 3 |
| Jobs CI/CD | 6 |
| Lignes de code Python | ~150 |
| Lignes de code JavaScript | ~200 |
| TPs complétés | 5/5 |

---

## 🔗 Liens utiles

### Documentation générale
- [README principal](../README.md)
- [CHANGELOG](../CHANGELOG.md)
- [CONTRIBUTING](../CONTRIBUTING.md)

### Guides détaillés
- [TP4-GUIDE](../TP4-GUIDE.md) - Simulation erreurs
- [TP5-GUIDE](../TP5-GUIDE.md) - Releases détaillées
- [TP6-GUIDE](../TP6-GUIDE.md) - Déploiement complet

### Workflows
- [CI/CD Architecture](../.github/CI-CD-ARCHITECTURE.md)
- [Troubleshooting](../.github/TROUBLESHOOTING.md)
- [Workflows README](../.github/workflows/README.md)

---

## 📝 Comment utiliser cette documentation

### Pour les étudiants

1. **Lire les objectifs** de chaque TP
2. **Suivre les consignes** étape par étape
3. **Vérifier les critères** de validation
4. **Fournir les livrables** demandés

### Pour les enseignants

1. **Évaluer les livrables** selon les critères
2. **Vérifier le fonctionnement** avec les instructions
3. **Consulter les ressources** pour approfondir

### Pour les développeurs

1. **Comprendre l'architecture** du projet
2. **Reproduire le setup** en local
3. **Contribuer** selon CONTRIBUTING.md

---

## 🎓 Compétences acquises

### DevOps
- ✅ Versionnement avec Git
- ✅ Conteneurisation avec Docker
- ✅ Orchestration avec Docker Compose
- ✅ CI/CD avec GitHub Actions
- ✅ Tests automatisés
- ✅ Releases et versioning
- ✅ Déploiement cloud

### Développement
- ✅ Backend REST API (FastAPI)
- ✅ Frontend web (HTML/CSS/JS)
- ✅ Base de données (PostgreSQL)
- ✅ Tests unitaires (Pytest)
- ✅ Async JavaScript (Fetch API)

### Méthodologie
- ✅ Commits conventionnels
- ✅ Documentation technique
- ✅ Semantic Versioning
- ✅ Infrastructure as Code
- ✅ Continuous Integration
- ✅ Continuous Deployment

---

## 🏆 Projet complet

Ce projet DevOps couvre **l'intégralité du cycle de vie** d'une application web moderne :

1. **Développement** (TP2) : Code source versionné
2. **Construction** (TP3) : Build automatisé
3. **Validation** (TP4) : Tests automatiques
4. **Release** (TP5) : Gestion des versions
5. **Déploiement** (TP6) : Production automatisée

**Félicitations pour avoir complété tous les TPs ! 🎉**
