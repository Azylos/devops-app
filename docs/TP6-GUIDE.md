# TP6 - DEPLOY : Déploiement automatisé

## Objectif

Déployer automatiquement l'application sur un environnement distant accessible publiquement.

---

## 🎯 Options de déploiement

Ce guide couvre **3 stratégies de déploiement** :

| Option | Difficulté | Coût | Avantages |
|--------|-----------|------|-----------|
| **DockerHub + Render** | ⭐⭐ Facile | Gratuit | Simple, UI friendly |
| **DockerHub + Railway** | ⭐⭐ Facile | Gratuit* | Déploiement automatique |
| **DockerHub + Fly.io** | ⭐⭐⭐ Moyen | Gratuit* | Plus de contrôle |

*Gratuit avec limitations

---

## 📦 Partie 1 : Publication sur DockerHub

### 1.1 Créer un compte DockerHub

1. Aller sur [hub.docker.com](https://hub.docker.com/)
2. Créer un compte gratuit
3. Vérifier votre email

### 1.2 Créer un Access Token

1. Aller sur **Account Settings** → **Security** → **New Access Token**
2. Nom du token : `github-actions-devops-app`
3. Permissions : **Read, Write, Delete**
4. Copier le token (vous ne le reverrez plus !)

### 1.3 Ajouter les secrets GitHub

1. Aller sur votre repo GitHub → **Settings** → **Secrets and variables** → **Actions**
2. Cliquer sur **New repository secret**
3. Ajouter deux secrets :

```
Nom: DOCKERHUB_USERNAME
Valeur: votre-username-dockerhub

Nom: DOCKERHUB_TOKEN
Valeur: le-token-copié-précédemment
```

### 1.4 Mettre à jour le workflow

Le workflow [.github/workflows/release.yml](.github/workflows/release.yml) a été mis à jour pour publier sur DockerHub ET GitHub Container Registry.

**Nouvelles fonctionnalités :**
- ✅ Login DockerHub automatique
- ✅ Build multi-plateforme (linux/amd64, linux/arm64)
- ✅ Publication simultanée sur ghcr.io et DockerHub
- ✅ Tags automatiques : version + latest

### 1.5 Tester la publication

```bash
# Créer un nouveau tag
git tag -a v1.0.1 -m "Release v1.0.1 - Test DockerHub"
git push origin v1.0.1

# Observer le workflow
# GitHub → Actions → "Release"

# Vérifier sur DockerHub
# hub.docker.com → Repositories
# Vous devriez voir :
#   - votreusername/devops-app-backend:v1.0.1
#   - votreusername/devops-app-backend:latest
#   - votreusername/devops-app-frontend:v1.0.1
#   - votreusername/devops-app-frontend:latest
```

---

## 🚀 Partie 2 : Déploiement sur Render

**Render** est une plateforme PaaS gratuite parfaite pour les projets étudiants.

### 2.1 Créer un compte Render

1. Aller sur [render.com](https://render.com/)
2. S'inscrire avec GitHub (recommandé)
3. Vérifier votre email

### 2.2 Déployer le Backend

#### Créer un nouveau Web Service

1. Dashboard Render → **New** → **Web Service**
2. Connecter votre repo GitHub `devops-app`
3. Configurer :

```
Name: devops-app-backend
Region: Frankfurt (EU Central)
Branch: main
Root Directory: backend
Runtime: Docker
Dockerfile Path: backend/Dockerfile

Instance Type: Free

Environment Variables:
  DATABASE_URL: (laisser vide pour l'instant)
```

4. Cliquer sur **Create Web Service**

#### Obtenir l'URL publique

Une fois déployé (3-5 min), vous obtiendrez :
```
https://devops-app-backend.onrender.com
```

Tester :
```bash
curl https://devops-app-backend.onrender.com/articles
```

### 2.3 Déployer le Frontend

#### Créer un deuxième Web Service

1. Dashboard → **New** → **Web Service**
2. Sélectionner le même repo
3. Configurer :

```
Name: devops-app-frontend
Region: Frankfurt (EU Central)
Branch: main
Root Directory: frontend
Runtime: Docker
Dockerfile Path: frontend/Dockerfile

Instance Type: Free

Environment Variables:
  BACKEND_URL: https://devops-app-backend.onrender.com
```

4. Cliquer sur **Create Web Service**

#### Mettre à jour le frontend pour utiliser l'URL du backend

Modifier [frontend/public/index.html](frontend/public/index.html) :

```javascript
// Ancienne version
const API_URL = 'http://backend:8000/articles';

// Nouvelle version
const API_URL = 'https://devops-app-backend.onrender.com/articles';
```

Ou mieux, utiliser une variable d'environnement :

```javascript
const API_URL = window.ENV?.BACKEND_URL || 'http://localhost:8000/articles';
```

### 2.4 Déploiement automatique

Render se redéploie automatiquement à chaque push sur `main` !

**Workflow :**
```
git push origin main
    ↓
Render détecte le push
    ↓
Rebuild automatique
    ↓
Application mise à jour (2-3 min)
```

---

## 🚂 Partie 3 : Déploiement sur Railway

**Railway** offre un déploiement encore plus simple avec $5 de crédit gratuit.

### 3.1 Créer un compte Railway

1. Aller sur [railway.app](https://railway.app/)
2. S'inscrire avec GitHub
3. Vérifier votre email

### 3.2 Déployer avec railway.json

#### Créer le fichier de configuration

Créer `railway.json` à la racine :

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "backend/Dockerfile"
  },
  "deploy": {
    "startCommand": "uvicorn main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/",
    "restartPolicyType": "ON_FAILURE"
  }
}
```

### 3.3 Déployer

1. Dashboard Railway → **New Project** → **Deploy from GitHub repo**
2. Sélectionner `devops-app`
3. Railway détecte automatiquement Docker
4. Attendre le déploiement (2-3 min)

#### Obtenir l'URL

Railway génère une URL :
```
https://devops-app-production.up.railway.app
```

### 3.4 Déploiement automatique

Railway se redéploie automatiquement sur chaque push !

---

## ✈️ Partie 4 : Déploiement sur Fly.io

**Fly.io** offre le plus de contrôle avec une CLI puissante.

### 4.1 Installation

```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Windows
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"

# Vérifier l'installation
flyctl version
```

### 4.2 Créer un compte

```bash
flyctl auth signup
# Ou si vous avez déjà un compte
flyctl auth login
```

### 4.3 Déployer le backend

```bash
cd backend

# Initialiser l'app Fly.io
flyctl launch

# Configuration interactive :
# App name: devops-app-backend
# Region: Paris (cdg)
# PostgreSQL: No (pour l'instant)
# Redis: No
# Deploy now: Yes

# L'app est déployée !
flyctl open
```

### 4.4 Fichier fly.toml généré

```toml
app = "devops-app-backend"
primary_region = "cdg"

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "8080"

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 256
```

### 4.5 Déploiement automatique avec GitHub Actions

Créer `.github/workflows/deploy-fly.yml` (voir fichier créé).

---

## 🔄 Partie 5 : Pipeline de déploiement complet

### Workflow automatisé

```
Developer
    ↓
git push origin main
    ↓
GitHub Actions (CI)
  ✅ Tests
  ✅ Lint
  ✅ Build
    ↓
Merge to main
    ↓
git tag v1.0.1
    ↓
GitHub Actions (Release)
  📦 Build images
  🐳 Push to DockerHub
  📦 Push to ghcr.io
    ↓
Platform (Render/Railway/Fly.io)
  🚀 Auto-deploy
  🌍 Application live !
```

---

## ✅ Checklist de déploiement

### Avant le déploiement

- [ ] Tous les tests passent localement
- [ ] CHANGELOG.md mis à jour
- [ ] Variables d'environnement documentées
- [ ] Images Docker fonctionnent localement
- [ ] CORS configuré pour le domaine de production

### Configuration DockerHub

- [ ] Compte DockerHub créé
- [ ] Access Token généré
- [ ] Secrets GitHub configurés (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN)
- [ ] Workflow release.yml mis à jour

### Déploiement Render

- [ ] Compte Render créé
- [ ] Backend déployé
- [ ] Frontend déployé
- [ ] URLs publiques obtenues
- [ ] Tests de santé réussis

### Post-déploiement

- [ ] Application accessible publiquement
- [ ] API retourne les données correctes
- [ ] Frontend affiche les articles
- [ ] Logs vérifiés (pas d'erreurs)
- [ ] Déploiement automatique testé

---

## 🔗 URLs de l'application déployée

Après déploiement, vous aurez :

### Render
```
Backend:  https://devops-app-backend.onrender.com
Frontend: https://devops-app-frontend.onrender.com
API:      https://devops-app-backend.onrender.com/articles
Docs:     https://devops-app-backend.onrender.com/docs
```

### Railway
```
Backend:  https://devops-app-production.up.railway.app
Frontend: https://devops-app-frontend-production.up.railway.app
```

### Fly.io
```
Backend:  https://devops-app-backend.fly.dev
Frontend: https://devops-app-frontend.fly.dev
```

---

## 🐛 Dépannage

### Les images DockerHub ne se publient pas

1. Vérifier les secrets GitHub :
   ```bash
   # Aller sur GitHub → Settings → Secrets
   # Vérifier DOCKERHUB_USERNAME et DOCKERHUB_TOKEN
   ```

2. Vérifier les logs du workflow :
   ```
   GitHub → Actions → Release → publish-docker
   ```

### Render : Build échoue

1. Vérifier les logs de build :
   ```
   Render Dashboard → Service → Logs
   ```

2. Vérifier le Dockerfile :
   ```bash
   # Tester localement
   docker build -t test-backend ./backend
   docker run -p 8000:8000 test-backend
   ```

### CORS bloque les requêtes

Mettre à jour `backend/main.py` :

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://devops-app-frontend.onrender.com",
        "http://localhost:3000"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 📊 Comparaison des plateformes

| Critère | Render | Railway | Fly.io |
|---------|--------|---------|--------|
| Gratuit | ✅ Oui | ✅ $5/mois | ✅ Limité |
| Auto-deploy | ✅ Oui | ✅ Oui | ⚠️ Via GH Actions |
| CLI | ❌ Non | ✅ Oui | ✅ Oui |
| Facilité | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Performance | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Databases | ✅ PostgreSQL | ✅ PostgreSQL | ✅ PostgreSQL |

**Recommandation pour le TP :** **Render** (le plus simple pour débuter)

---

## 🎯 Validation du TP6

### Livrables

- [x] **Compte créé** sur DockerHub ✅
- [x] **Workflow GitHub Actions** configuré pour DockerHub ✅
- [x] **Images Docker publiées** automatiquement ✅
- [x] **Application déployée** et accessible publiquement ✅
- [x] **Lien vers l'application** fourni ✅
- [x] **Pipeline de déploiement** fonctionnel ✅

### Test final

```bash
# Tester l'API en production
curl https://votre-backend.onrender.com/articles

# Résultat attendu : Liste des articles en JSON
[
  {
    "id": 1,
    "titre": "Introduction à FastAPI",
    ...
  }
]
```

---

## 📝 Exemple de livrable

**Lien vers l'application en ligne :**
- Frontend : https://devops-app-frontend.onrender.com
- Backend API : https://devops-app-backend.onrender.com/articles
- Documentation : https://devops-app-backend.onrender.com/docs

**Pipeline de déploiement :**
- Images DockerHub : https://hub.docker.com/r/votreusername/devops-app-backend
- GitHub Actions : https://github.com/votreusername/devops-app/actions
- Workflow Release : [.github/workflows/release.yml](.github/workflows/release.yml)

**Déploiement automatique activé :**
- ✅ Push sur `main` → Render redéploie automatiquement
- ✅ Nouveau tag `v*.*.*` → GitHub Actions publie sur DockerHub
- ✅ Application accessible 24/7

**TP6 complété avec succès ! 🎉**
