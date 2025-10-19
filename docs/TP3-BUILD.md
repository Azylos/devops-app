# TP3 – BUILD : Intégration continue & conteneurisation

## 📋 Objectif

Automatiser la construction et la vérification du projet avec Docker et GitHub Actions.

---

## 📝 Consignes

### 1. Dockerfile pour le backend FastAPI

**Créer `backend/Dockerfile` :**

```dockerfile
# Image Python officielle
FROM python:3.11-slim

# Répertoire de travail
WORKDIR /app

# Copier les dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code
COPY . .

# Exposer le port
EXPOSE 8000

# Démarrer l'application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Tester :**
```bash
cd backend
docker build -t devops-backend .
docker run -p 8000:8000 devops-backend
```

### 2. Dockerfile pour le frontend Node.js

**Créer `frontend/package.json` :**
```json
{
  "name": "devops-frontend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

**Créer `frontend/server.js` :**
```javascript
const express = require('express');
const path = require('path');

const app = express();
app.use(express.static('public'));

app.listen(3000, () => {
    console.log('Frontend on http://localhost:3000');
});
```

**Créer `frontend/Dockerfile` :**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### 3. Docker Compose avec 3 services

**Créer `docker-compose.yml` à la racine :**

```yaml
version: '3.8'

services:
  # PostgreSQL
  db:
    image: postgres:15-alpine
    container_name: devops_db
    environment:
      POSTGRES_USER: devops_user
      POSTGRES_PASSWORD: devops_password
      POSTGRES_DB: devops_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - devops_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U devops_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Backend FastAPI
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: devops_backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://devops_user:devops_password@db:5432/devops_db
    depends_on:
      db:
        condition: service_healthy
    networks:
      - devops_network

  # Frontend Node.js
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: devops_frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - devops_network

networks:
  devops_network:
    driver: bridge

volumes:
  postgres_data:
```

### 4. Vérifier le bon fonctionnement

```bash
# Démarrer tous les services
docker-compose up -d --build

# Vérifier le statut
docker-compose ps

# Tester les services
curl http://localhost:8000/articles
curl http://localhost:3000

# Voir les logs
docker-compose logs -f

# Arrêter
docker-compose down
```

### 5. GitHub Actions CI

**Créer `.github/workflows/ci.yml` :**

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test-backend:
    name: Tests Backend
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'

      - name: Install dependencies
        working-directory: ./backend
        run: |
          pip install -r requirements.txt
          pip install pytest httpx

      - name: Run tests
        working-directory: ./backend
        run: pytest -v

  build-docker:
    name: Build Docker Images
    runs-on: ubuntu-latest
    needs: test-backend

    strategy:
      matrix:
        service: [backend, frontend]

    steps:
      - uses: actions/checkout@v4

      - name: Build ${{ matrix.service }}
        run: |
          docker build -t test-${{ matrix.service }} ./${{ matrix.service }}
          echo "✓ Image ${{ matrix.service }} built successfully"
```

**Créer des tests backend (`backend/test_main.py`) :**

```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200

def test_get_articles():
    response = client.get("/articles")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

---

## ✅ Livrable

**Fichiers à fournir :**

✅ `backend/Dockerfile`
✅ `frontend/Dockerfile`
✅ `docker-compose.yml`
✅ `.github/workflows/ci.yml`
✅ Capture d'écran de `docker-compose ps` montrant les 3 services
✅ Lien vers le pipeline GitHub Actions

**Exemple :**
- Repository : https://github.com/votreusername/devops-app
- Actions : https://github.com/votreusername/devops-app/actions

---

## 🎯 Critères de validation

- [ ] Dockerfile backend construit sans erreur
- [ ] Dockerfile frontend construit sans erreur
- [ ] docker-compose.yml démarre les 3 services
- [ ] Réseau commun `devops_network` créé
- [ ] Tests unitaires backend passent
- [ ] Pipeline CI exécuté sur GitHub Actions
- [ ] Badge CI vert sur le repository

---

## 🐛 Dépannage

### Les containers ne démarrent pas
```bash
# Voir les logs
docker-compose logs

# Reconstruire
docker-compose down -v
docker-compose up -d --build
```

### Port déjà utilisé
```bash
# Modifier le port dans docker-compose.yml
ports:
  - "8001:8000"  # Au lieu de 8000:8000
```

### Tests échouent
```bash
# Installer les dépendances de test
cd backend
pip install pytest httpx
pytest -v
```

---

## 📚 Ressources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [GitHub Actions](https://docs.github.com/actions)
- [Pytest](https://docs.pytest.org/)

---

## 🏗️ Architecture finale

```
┌─────────────────┐
│   Frontend      │
│   Node.js:3000  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Backend       │
│   FastAPI:8000  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Database      │
│   PostgreSQL    │
│   :5432         │
└─────────────────┘
```

**TP3 complété ! 🎉**
