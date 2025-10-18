"""
Tests de l'API - TP4
Validation de la qualité avec Pytest
"""
import pytest
from fastapi.testclient import TestClient
from main import app

# Client de test FastAPI
client = TestClient(app)


def test_articles_status_code():
    """
    Test que la route /articles renvoie un status_code == 200
    """
    response = client.get("/articles")
    assert response.status_code == 200, f"Expected 200, got {response.status_code}"


def test_articles_returns_json():
    """
    Test que la route /articles renvoie du JSON
    """
    response = client.get("/articles")
    assert response.status_code == 200
    assert response.headers["content-type"] == "application/json"


def test_articles_returns_list():
    """
    Test que la route /articles renvoie une liste
    """
    response = client.get("/articles")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list), "La réponse doit être une liste"


def test_articles_not_empty():
    """
    Test que la route /articles renvoie au moins un article
    """
    response = client.get("/articles")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0, "La liste des articles ne doit pas être vide"


def test_article_has_required_fields():
    """
    Test que chaque article contient les champs requis
    """
    response = client.get("/articles")
    assert response.status_code == 200
    articles = response.json()

    required_fields = ["id", "titre", "contenu", "auteur", "date"]

    for article in articles:
        for field in required_fields:
            assert field in article, f"Le champ '{field}' est manquant dans l'article {article.get('id', 'unknown')}"
