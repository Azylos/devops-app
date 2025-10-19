# TP4 – TEST : Validation de la qualité

## 📋 Objectif

Automatiser les tests de l'application dans la CI pour garantir la qualité du code.

---

## 📝 Consignes

### 1. Créer test_api.py avec Pytest

**Créer `backend/test_api.py` :**

```python
"""
Tests de l'API - TP4
Validation que /articles renvoie status_code == 200
"""
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_articles_status_code():
    """
    Test principal : vérifie que /articles renvoie 200
    """
    response = client.get("/articles")
    assert response.status_code == 200, \
        f"Expected 200, got {response.status_code}"


def test_articles_returns_json():
    """Test que la réponse est du JSON"""
    response = client.get("/articles")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/json"


def test_articles_returns_list():
    """Test que la réponse est une liste"""
    response = client.get("/articles")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)


def test_articles_not_empty():
    """Test que la liste contient au moins un article"""
    response = client.get("/articles")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0


def test_article_has_required_fields():
    """Test que chaque article a les champs requis"""
    response = client.get("/articles")
    assert response.status_code == 200
    articles = response.json()

    required_fields = ["id", "titre", "contenu", "auteur", "date"]

    for article in articles:
        for field in required_fields:
            assert field in article, \
                f"Champ '{field}' manquant dans article {article.get('id')}"
```

**Installer les dépendances de test :**

Mettre à jour `backend/requirements.txt` :
```
fastapi==0.115.0
uvicorn[standard]==0.32.0
pytest==7.4.3
httpx==0.25.2
```

**Tester localement :**
```bash
cd backend
pip install -r requirements.txt
pytest -v

# Résultat attendu :
# test_api.py::test_articles_status_code PASSED
# test_api.py::test_articles_returns_json PASSED
# test_api.py::test_articles_returns_list PASSED
# test_api.py::test_articles_not_empty PASSED
# test_api.py::test_article_has_required_fields PASSED
# ============ 5 passed in 0.50s ============
```

### 2. Ajouter l'exécution des tests dans GitHub Actions

Le workflow `.github/workflows/ci.yml` contient déjà :

```yaml
jobs:
  test-backend:
    name: Tests Backend FastAPI
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
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Run tests with pytest
        working-directory: ./backend
        run: |
          pytest -v --tb=short
```

**Vérifier que les tests s'exécutent :**
```bash
git add backend/test_api.py
git commit -m "test: ajout tests validation /articles"
git push origin main

# Aller sur GitHub → Actions
# Observer le workflow qui s'exécute
```

### 3. Simuler une erreur et valider la détection

**Étape 1 : Créer une version avec erreur**

Créer `backend/main_avec_erreur.py` :
```python
from fastapi import FastAPI, HTTPException
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
    """
    ⚠️ ERREUR INTENTIONNELLE ⚠️
    Cette route lève une exception 500
    """
    raise HTTPException(
        status_code=500,
        detail="Erreur intentionnelle TP4"
    )
```

**Étape 2 : Activer l'erreur**
```bash
cd backend
mv main.py main_backup.py
mv main_avec_erreur.py main.py
```

**Étape 3 : Tester localement**
```bash
pytest -v

# Résultat attendu (ÉCHEC) :
# test_api.py::test_articles_status_code FAILED
# AssertionError: Expected 200, got 500
# ============ 1 failed, 4 passed ============
```

**Étape 4 : Commiter et observer l'échec du CI**
```bash
git add .
git commit -m "test: simulation erreur TP4"
git push origin main

# GitHub → Actions → Observer l'échec ❌
```

**Étape 5 : Corriger l'erreur**
```bash
cd backend
rm main.py
mv main_backup.py main.py
```

**Étape 6 : Tester la correction**
```bash
pytest -v

# Résultat attendu (SUCCÈS) :
# ============ 5 passed in 0.50s ============
```

**Étape 7 : Commiter la correction**
```bash
git add .
git commit -m "fix: correction erreur TP4"
git push origin main

# GitHub → Actions → Observer le succès ✅
```

---

## ✅ Livrable

**Fichiers à fournir :**

✅ `backend/test_api.py`
✅ Capture d'écran du pipeline "vert" (tous tests passent)
✅ Capture d'écran du pipeline "rouge" (échec simulé)
✅ Lien vers les runs GitHub Actions

**Exemple de captures :**

1. **Pipeline vert (succès) :**
   - GitHub Actions → ✅ All checks passed
   - 5 tests passed

2. **Pipeline rouge (échec simulé) :**
   - GitHub Actions → ❌ Some checks failed
   - 1 test failed, 4 passed

---

## 🎯 Critères de validation

- [ ] Fichier `test_api.py` créé
- [ ] Test `test_articles_status_code` vérifie status == 200
- [ ] Tests exécutés dans GitHub Actions
- [ ] Pipeline échoue quand erreur introduite
- [ ] Pipeline réussit après correction
- [ ] Captures d'écran fournies (vert et rouge)

---

## 🔍 Workflow de validation

```
Code correct
    ↓
pytest -v → ✅ 5 passed
    ↓
git push → GitHub Actions ✅
    ↓
Introduction erreur (status 500)
    ↓
pytest -v → ❌ 1 failed, 4 passed
    ↓
git push → GitHub Actions ❌
    ↓
Correction erreur
    ↓
pytest -v → ✅ 5 passed
    ↓
git push → GitHub Actions ✅
```

---

## 🛠️ Script d'aide

**Créer `backend/simulate_error.sh` :**
```bash
#!/bin/bash

case "$1" in
    enable)
        echo "🔴 Activation de l'erreur..."
        mv main.py main_backup.py
        mv main_avec_erreur.py main.py
        echo "✅ Erreur activée"
        ;;
    disable)
        echo "🟢 Désactivation de l'erreur..."
        mv main_backup.py main.py
        echo "✅ Erreur désactivée"
        ;;
    *)
        echo "Usage: $0 {enable|disable}"
        exit 1
        ;;
esac
```

**Utilisation :**
```bash
chmod +x simulate_error.sh
./simulate_error.sh enable   # Active l'erreur
./simulate_error.sh disable  # Désactive l'erreur
```

---

## 📊 Exemple de résultats

### Tests réussis ✅
```
test_api.py::test_articles_status_code PASSED           [20%]
test_api.py::test_articles_returns_json PASSED          [40%]
test_api.py::test_articles_returns_list PASSED          [60%]
test_api.py::test_articles_not_empty PASSED             [80%]
test_api.py::test_article_has_required_fields PASSED    [100%]

============ 5 passed in 0.50s ============
```

### Tests échoués ❌
```
test_api.py::test_articles_status_code FAILED           [20%]

FAILED test_api.py::test_articles_status_code
AssertionError: Expected 200, got 500

============ 1 failed, 4 passed in 0.50s ============
```

---

## 📚 Ressources

- [Pytest Documentation](https://docs.pytest.org/)
- [FastAPI Testing](https://fastapi.tiangolo.com/tutorial/testing/)
- [GitHub Actions Status](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows)

**TP4 complété ! 🎉**
