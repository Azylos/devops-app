# TP2 – CODE : Développement collaboratif

## 📋 Objectif

Mettre en place le code source versionné de l'application.

---

## 📝 Consignes

### 1. Créer un repository GitHub public

**Nom :** `devops-app`

**Étapes :**
```bash
# Initialiser Git
git init

# Créer le repository sur GitHub
# Settings → Public

# Lier le repository local
git remote add origin https://github.com/votreusername/devops-app.git
```

### 2. Structurer le projet

```
devops-app/
├── frontend/     # Application web
├── backend/      # API FastAPI
└── db/          # Scripts base de données
```

**Commandes :**
```bash
mkdir frontend backend db
git add .
git commit -m "feat: structure initiale du projet"
```

### 3. Backend - API FastAPI

**Créer dans `backend/` :**

**`main.py` :**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Bienvenue sur l'API DevOps"}

@app.get("/articles")
def get_articles():
    articles = [
        {
            "id": 1,
            "titre": "Introduction à FastAPI",
            "contenu": "FastAPI est un framework web moderne...",
            "auteur": "Jean Dupont",
            "date": "2025-01-15"
        },
        {
            "id": 2,
            "titre": "Les bases de JavaScript",
            "contenu": "JavaScript est le langage du web...",
            "auteur": "Marie Martin",
            "date": "2025-01-16"
        }
    ]
    return articles
```

**`requirements.txt` :**
```
fastapi==0.115.0
uvicorn[standard]==0.32.0
```

**Tester :**
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload

# Accéder à http://localhost:8000/articles
```

### 4. Frontend - Page HTML/JS

**Créer dans `frontend/` :**

**`index.html` :**
```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Articles DevOps</title>
</head>
<body>
    <h1>Articles DevOps</h1>
    <div id="articles"></div>

    <script>
        const API_URL = 'http://localhost:8000/articles';

        async function loadArticles() {
            const response = await fetch(API_URL);
            const articles = await response.json();

            const container = document.getElementById('articles');
            articles.forEach(article => {
                const div = document.createElement('div');
                div.innerHTML = `
                    <h2>${article.titre}</h2>
                    <p>${article.contenu}</p>
                    <small>Par ${article.auteur} - ${article.date}</small>
                `;
                container.appendChild(div);
            });
        }

        window.addEventListener('DOMContentLoaded', loadArticles);
    </script>
</body>
</html>
```

**Tester :**
```bash
# Ouvrir index.html dans le navigateur
# Les articles s'affichent automatiquement
```

### 5. Commits et pushs avec messages clairs

**Exemple de workflow Git :**
```bash
# Backend
git add backend/
git commit -m "feat: création API FastAPI avec route /articles"

# Frontend
git add frontend/
git commit -m "feat: création page HTML avec fetch() des articles"

# Push
git push origin main
```

**Conventions de messages :**
- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation
- `style:` - Formatage
- `refactor:` - Refactorisation
- `test:` - Ajout de tests

---

## ✅ Livrable

**Lien vers le repository GitHub contenant :**

✅ Structure du projet (frontend/, backend/, db/)
✅ Code backend avec route `/articles`
✅ Code frontend avec `fetch()`
✅ Commits visibles avec messages clairs
✅ README.md avec instructions

**Exemple :** https://github.com/votreusername/devops-app

---

## 🎯 Critères de validation

- [ ] Repository GitHub public créé
- [ ] Structure frontend/backend/db présente
- [ ] Route `/articles` retourne du JSON
- [ ] Page HTML affiche les articles
- [ ] Minimum 3 commits avec messages explicites
- [ ] README avec instructions de démarrage

---

## 📚 Ressources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Fetch API](https://developer.mozilla.org/fr/docs/Web/API/Fetch_API)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Basics](https://git-scm.com/book/fr/v2)

---

## 🔗 Fichiers du projet

```
devops-app/
├── backend/
│   ├── main.py
│   └── requirements.txt
├── frontend/
│   └── index.html
├── db/
│   └── (vide pour l'instant)
└── README.md
```

**TP2 complété ! 🎉**
