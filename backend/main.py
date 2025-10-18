from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Configuration CORS pour permettre les requêtes depuis le frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifier les origines autorisées
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
    Retourne une liste d'articles au format JSON
    """
    articles = [
        {
            "id": 1,
            "titre": "Introduction à FastAPI",
            "contenu": "FastAPI est un framework web moderne et rapide pour construire des APIs avec Python.",
            "auteur": "Jean Dupont",
            "date": "2025-01-15"
        },
        {
            "id": 2,
            "titre": "Les bases de JavaScript",
            "contenu": "JavaScript est le langage de programmation du web, essentiel pour le développement frontend.",
            "auteur": "Marie Martin",
            "date": "2025-01-16"
        },
        {
            "id": 3,
            "titre": "DevOps et CI/CD",
            "contenu": "Les pratiques DevOps permettent d'automatiser et d'améliorer le processus de développement logiciel.",
            "auteur": "Pierre Durand",
            "date": "2025-01-17"
        },
        {
            "id": 4,
            "titre": "Docker pour les débutants",
            "contenu": "Docker permet de conteneuriser vos applications pour un déploiement simplifié.",
            "auteur": "Sophie Bernard",
            "date": "2025-01-18"
        }
    ]
    return articles
