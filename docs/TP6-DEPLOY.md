# TP6 – DEPLOY : Déploiement automatisé

## 📋 Objectif

Déployer automatiquement l'application sur un environnement distant accessible publiquement.

---

## 📝 Consignes

### 1. Créer un compte sur une plateforme

**Options recommandées :**

| Plateforme | Avantages | Gratuit |
|------------|-----------|---------|
| **Render** | Simple, UI friendly | ✅ Oui |
| **Railway** | Auto-deploy, moderne | ✅ $5/mois |
| **Fly.io** | CLI puissante, contrôle | ✅ Limité |
| **DockerHub** | Registry images | ✅ Oui |

**Pour le TP, utiliser Render (le plus simple) :**

1. Aller sur [render.com](https://render.com/)
2. S'inscrire avec GitHub
3. Vérifier l'email

### 2. Configurer GitHub Actions

**A. Publication sur DockerHub**

**Étape 1 : Créer un compte DockerHub**
- Aller sur [hub.docker.com](https://hub.docker.com/)
- Créer un compte gratuit

**Étape 2 : Créer un Access Token**
- Settings → Security → New Access Token
- Nom : `github-actions-devops`
- Permissions : Read, Write, Delete
- Copier le token

**Étape 3 : Ajouter les secrets GitHub**
- Repository → Settings → Secrets → Actions
- Nouveau secret `DOCKERHUB_USERNAME` : votre username
- Nouveau secret `DOCKERHUB_TOKEN` : le token copié

**Étape 4 : Workflow déjà configuré**

Le fichier `.github/workflows/release.yml` publie automatiquement sur DockerHub :

```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  publish-docker:
    name: Build & Push Docker Hub
    runs-on: ubuntu-latest

    strategy:
      matrix:
        service: [backend, frontend]

    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - name: Login DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build & Push
        uses: docker/build-push-action@v6
        with:
          context: ./${{ matrix.service }}
          push: true
          platforms: linux/amd64,linux/arm64
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/devops-app-${{ matrix.service }}:latest
            ${{ secrets.DOCKERHUB_USERNAME }}/devops-app-${{ matrix.service }}:${{ github.ref_name }}
```

**Tester :**
```bash
git tag -a v1.0.1 -m "Release v1.0.1 - Test DockerHub"
git push origin v1.0.1

# Vérifier sur hub.docker.com
# Images disponibles :
# - votreusername/devops-app-backend:v1.0.1
# - votreusername/devops-app-backend:latest
# - votreusername/devops-app-frontend:v1.0.1
# - votreusername/devops-app-frontend:latest
```

**B. Déploiement automatique**

Le workflow peut aussi déclencher un déploiement sur Render :

```yaml
  deploy-render:
    name: Deploy to Render
    needs: publish-docker
    runs-on: ubuntu-latest

    steps:
      - name: Trigger Render Deploy
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.RENDER_API_KEY }}" \
            "https://api.render.com/v1/services/${{ secrets.RENDER_SERVICE_ID }}/deploys"
```

### 3. Déployer sur Render

**Étape 1 : Créer le service Backend**

1. Dashboard Render → **New** → **Web Service**
2. Connecter le repository GitHub
3. Configuration :
   ```
   Name: devops-app-backend
   Region: Frankfurt (EU Central)
   Branch: main
   Runtime: Docker
   Dockerfile Path: backend/Dockerfile

   Instance Type: Free

   Environment Variables:
   (laisser vide pour l'instant)
   ```
4. Créer le service

**Étape 2 : Créer le service Frontend**

1. Nouveau **Web Service**
2. Configuration :
   ```
   Name: devops-app-frontend
   Region: Frankfurt
   Branch: main
   Runtime: Docker
   Dockerfile Path: frontend/Dockerfile

   Instance Type: Free

   Environment Variables:
   BACKEND_URL: https://devops-app-backend.onrender.com
   ```

**Étape 3 : Vérifier le déploiement**

Render build automatiquement (3-5 min).

URLs générées :
```
Backend:  https://devops-app-backend.onrender.com
Frontend: https://devops-app-frontend.onrender.com
```

**Étape 4 : Tester l'application**

```bash
# Tester l'API
curl https://devops-app-backend.onrender.com/articles

# Ouvrir le frontend
open https://devops-app-frontend.onrender.com
```

---

## ✅ Livrable

**À fournir :**

✅ **Lien vers l'application en ligne**
- Frontend : https://devops-app-frontend.onrender.com
- Backend : https://devops-app-backend.onrender.com/articles
- API Docs : https://devops-app-backend.onrender.com/docs

✅ **Pipeline de déploiement**
- DockerHub : https://hub.docker.com/r/votreusername/devops-app-backend
- GitHub Actions : https://github.com/votreusername/devops-app/actions
- Workflow : `.github/workflows/release.yml`

✅ **Capture d'écran**
- Application accessible publiquement
- Dashboard Render montrant les services
- DockerHub avec les images

✅ **Documentation**
- Instructions de déploiement dans README
- Variables d'environnement documentées

---

## 🎯 Critères de validation

- [ ] Compte créé sur plateforme de déploiement
- [ ] Compte DockerHub créé
- [ ] Secrets GitHub configurés
- [ ] Workflow publie sur DockerHub automatiquement
- [ ] Backend déployé et accessible
- [ ] Frontend déployé et accessible
- [ ] API retourne des données correctes
- [ ] Frontend affiche les articles
- [ ] Application accessible 24/7

---

## 🔄 Pipeline de déploiement complet

```
Developer
    ↓
git push origin main
    ↓
GitHub Actions CI
  ✅ Tests
  ✅ Lint
  ✅ Build
    ↓
git tag v1.0.1
git push origin v1.0.1
    ↓
GitHub Actions Release
  📦 Build images
  🐳 Push DockerHub
    - backend:v1.0.1
    - backend:latest
    - frontend:v1.0.1
    - frontend:latest
  📡 Trigger Render deploy (optionnel)
    ↓
Render Auto-Deploy
  🔄 Pull images DockerHub
  🚀 Restart services
  🌍 Application live !
    ↓
Application accessible
  🌐 https://devops-app.onrender.com
```

---

## 🌍 Options de déploiement

### Option A : Render (Recommandé pour le TP)

**Avantages :**
- ✅ Gratuit
- ✅ Interface simple
- ✅ Auto-deploy sur push
- ✅ HTTPS automatique

**Inconvénients :**
- ⚠️ Services s'arrêtent si inactifs (plan gratuit)
- ⚠️ Démarrage lent (~30s)

### Option B : Railway

**Avantages :**
- ✅ $5 gratuit/mois
- ✅ Déploiement super simple
- ✅ CLI moderne

**Inconvénients :**
- ⚠️ Crédit limité

### Option C : Fly.io

**Avantages :**
- ✅ CLI puissante
- ✅ Plus de contrôle
- ✅ Gratuit avec limitations

**Inconvénients :**
- ⚠️ Plus complexe
- ⚠️ Nécessite carte bancaire

---

## 🐛 Dépannage

### Images DockerHub ne se publient pas

```bash
# Vérifier les secrets
GitHub → Settings → Secrets → Actions
# S'assurer que DOCKERHUB_USERNAME et DOCKERHUB_TOKEN existent

# Vérifier les logs
GitHub → Actions → Release → publish-docker
```

### Render build échoue

```bash
# Voir les logs de build
Render Dashboard → Service → Logs

# Tester le Dockerfile localement
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

### Application inaccessible

1. Vérifier que les services sont démarrés sur Render
2. Vérifier les logs pour erreurs
3. Tester l'API directement : `curl URL/articles`

---

## 📊 Checklist de déploiement

### Avant déploiement
- [ ] Tests passent localement
- [ ] Build Docker fonctionne
- [ ] Variables d'environnement documentées

### Déploiement
- [ ] Compte plateforme créé
- [ ] Services backend et frontend créés
- [ ] URLs fonctionnelles
- [ ] API accessible
- [ ] Frontend affiche les données

### Après déploiement
- [ ] Application testée en production
- [ ] Logs vérifiés (pas d'erreurs)
- [ ] Documentation mise à jour avec URLs
- [ ] Déploiement automatique testé

---

## 📚 Ressources

- [Render Documentation](https://render.com/docs)
- [DockerHub](https://docs.docker.com/docker-hub/)
- [Railway Documentation](https://docs.railway.app/)
- [Fly.io Documentation](https://fly.io/docs/)

---

## 🎓 Exemple de livrable complet

**Application déployée :**
- 🌐 Frontend : https://devops-app-frontend.onrender.com
- 🔌 Backend : https://devops-app-backend.onrender.com
- 📚 API Docs : https://devops-app-backend.onrender.com/docs

**Pipeline de déploiement :**
- 🐳 DockerHub : https://hub.docker.com/r/votreusername/devops-app-backend
- ⚙️ GitHub Actions : https://github.com/votreusername/devops-app/actions

**Automatisation :**
- ✅ Push sur `main` → Render redéploie automatiquement
- ✅ Tag `v*.*.*` → DockerHub publie les images
- ✅ Application accessible 24/7

**TP6 complété ! 🎉**
