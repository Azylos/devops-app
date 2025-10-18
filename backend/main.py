"""
FICHIER DE DÉMONSTRATION - TP4
Ce fichier contient intentionnellement une ERREUR pour démontrer
la détection automatique des tests échoués dans le CI/CD.

POUR SIMULER L'ERREUR:
1. Renommer main.py en main_backup.py
2. Renommer main_avec_erreur.py en main.py
3. Commiter et pusher
4. Observer l'échec du CI/CD dans GitHub Actions
5. Revenir à la version correcte

ERREUR INTRODUITE:
- La route /articles retourne une erreur 500 au lieu de 200
- Les tests test_api.py échoueront
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Configuration CORS
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
    Cette route lève une exception pour simuler une erreur
    """
    # ERREUR: Lever une exception qui causera un status_code 500
    raise HTTPException(
        status_code=500,
        detail="Erreur intentionnelle pour démonstration TP4"
    )

    # Le code ci-dessous ne sera jamais exécuté
    articles = [
        {
            "id": 1,
            "titre": "Introduction à FastAPI",
            "contenu": "FastAPI est un framework web moderne et rapide.",
            "auteur": "Jean Dupont",
            "date": "2025-01-15"
        }
    ]
    return articles
