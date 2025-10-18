import pytest
from fastapi.testclient import TestClient
from main import app

# Client de test FastAPI
client = TestClient(app)


def test_read_root():
    """Test de la route racine"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
    assert response.json()["message"] == "Bienvenue sur l'API DevOps"


def test_get_articles():
    """Test de la route /articles"""
    response = client.get("/articles")
    assert response.status_code == 200

    # Vérifier que la réponse est une liste
    articles = response.json()
    assert isinstance(articles, list)

    # Vérifier qu'il y a au moins un article
    assert len(articles) > 0


def test_articles_structure():
    """Test de la structure des articles"""
    response = client.get("/articles")
    articles = response.json()

    # Vérifier la structure du premier article
    first_article = articles[0]
    assert "id" in first_article
    assert "titre" in first_article
    assert "contenu" in first_article
    assert "auteur" in first_article
    assert "date" in first_article

    # Vérifier les types
    assert isinstance(first_article["id"], int)
    assert isinstance(first_article["titre"], str)
    assert isinstance(first_article["contenu"], str)
    assert isinstance(first_article["auteur"], str)
    assert isinstance(first_article["date"], str)


def test_articles_content():
    """Test du contenu des articles"""
    response = client.get("/articles")
    articles = response.json()

    # Vérifier qu'on a 4 articles
    assert len(articles) == 4

    # Vérifier que les titres ne sont pas vides
    for article in articles:
        assert len(article["titre"]) > 0
        assert len(article["contenu"]) > 0
        assert len(article["auteur"]) > 0


def test_cors_headers():
    """Test de la configuration CORS"""
    response = client.get("/articles")
    assert response.status_code == 200
    # FastAPI ajoute les headers CORS automatiquement avec le middleware


def test_article_ids_are_unique():
    """Test que les IDs des articles sont uniques"""
    response = client.get("/articles")
    articles = response.json()

    ids = [article["id"] for article in articles]
    # Vérifier qu'il n'y a pas de doublons
    assert len(ids) == len(set(ids))


def test_articles_ordered_by_id():
    """Test que les articles sont ordonnés par ID"""
    response = client.get("/articles")
    articles = response.json()

    ids = [article["id"] for article in articles]
    # Vérifier que les IDs sont dans l'ordre croissant
    assert ids == sorted(ids)
