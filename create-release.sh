#!/bin/bash

# Script de création de release - TP5
# Usage: ./create-release.sh <version>
# Exemple: ./create-release.sh 1.0.0

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Erreur: Version non spécifiée"
    echo ""
    echo "Usage: $0 <version>"
    echo "Exemple: $0 1.0.0"
    echo ""
    echo "Format Semantic Versioning: MAJEUR.MINEUR.PATCH"
    echo "  - MAJEUR: Changements incompatibles (ex: 2.0.0)"
    echo "  - MINEUR: Nouvelles fonctionnalités (ex: 1.1.0)"
    echo "  - PATCH: Corrections de bugs (ex: 1.0.1)"
    exit 1
fi

# Ajouter le préfixe 'v' si absent
if [[ ! $VERSION =~ ^v ]]; then
    VERSION="v$VERSION"
fi

echo "🚀 Création de la release $VERSION"
echo ""

# 1. Vérifier qu'on est sur main
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Vous n'êtes pas sur la branche main (branche actuelle: $CURRENT_BRANCH)"
    read -p "Continuer quand même ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 2. Vérifier qu'il n'y a pas de changements non commités
if ! git diff-index --quiet HEAD --; then
    echo "❌ Erreur: Vous avez des changements non commités"
    echo ""
    git status --short
    echo ""
    echo "Veuillez commiter ou stasher vos changements avant de créer une release"
    exit 1
fi

# 3. Vérifier que le tag n'existe pas déjà
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "❌ Erreur: Le tag $VERSION existe déjà"
    echo ""
    echo "Tags existants:"
    git tag -l
    exit 1
fi

# 4. Pull les dernières modifications
echo "📥 Mise à jour depuis origin..."
git pull origin main

# 5. Vérifier que CHANGELOG.md existe et contient la version
if [ ! -f "CHANGELOG.md" ]; then
    echo "⚠️  CHANGELOG.md non trouvé"
    read -p "Créer CHANGELOG.md maintenant ? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        echo "## [${VERSION#v}] - $(date +%Y-%m-%d)" > CHANGELOG.md
        echo "" >> CHANGELOG.md
        echo "### Ajouté" >> CHANGELOG.md
        echo "- Première version" >> CHANGELOG.md
        git add CHANGELOG.md
        git commit -m "docs: ajout CHANGELOG.md pour $VERSION"
    fi
else
    VERSION_WITHOUT_V=${VERSION#v}
    if ! grep -q "\[$VERSION_WITHOUT_V\]" CHANGELOG.md; then
        echo "⚠️  La version $VERSION_WITHOUT_V n'est pas documentée dans CHANGELOG.md"
        read -p "Continuer quand même ? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            echo "Veuillez ajouter la section suivante dans CHANGELOG.md :"
            echo ""
            echo "## [$VERSION_WITHOUT_V] - $(date +%Y-%m-%d)"
            echo ""
            echo "### Ajouté"
            echo "- Vos changements ici"
            echo ""
            exit 1
        fi
    fi
fi

# 6. Lancer les tests
echo ""
echo "🧪 Lancement des tests..."
if [ -f "backend/test_main.py" ]; then
    cd backend
    if command -v pytest &> /dev/null; then
        if ! pytest -v --tb=short; then
            echo ""
            echo "❌ Les tests ont échoué"
            read -p "Créer la release quand même ? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            echo "✅ Tests réussis"
        fi
    else
        echo "⚠️  pytest non installé, tests ignorés"
    fi
    cd ..
fi

# 7. Créer le tag
echo ""
echo "🏷️  Création du tag $VERSION..."

# Message du tag
TAG_MESSAGE="Release $VERSION

$(awk "/## \[${VERSION#v}\]/,/## \[/{if(/## \[${VERSION#v}\]/)f=1;else if(/## \[/)f=0;if(f)print}" CHANGELOG.md 2>/dev/null || echo "Version $VERSION")"

git tag -a "$VERSION" -m "$TAG_MESSAGE"

echo "✅ Tag $VERSION créé"

# 8. Afficher les informations
echo ""
echo "📋 Informations de la release:"
echo "   Version: $VERSION"
echo "   Branche: $CURRENT_BRANCH"
echo "   Commit:  $(git rev-parse --short HEAD)"
echo ""

# 9. Demander confirmation pour pousser
read -p "Pousser le tag vers origin ? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo ""
    echo "📤 Push du tag vers origin..."
    git push origin "$VERSION"
    echo ""
    echo "✅ Release $VERSION créée avec succès !"
    echo ""
    echo "🔗 Prochaines étapes:"
    echo "   1. Aller sur GitHub → Actions"
    echo "   2. Observer le workflow 'Release'"
    echo "   3. Vérifier la release sur GitHub → Releases"
    echo "   4. Les images Docker seront publiées sur ghcr.io"
    echo ""
    echo "🐳 Images Docker qui seront publiées:"
    echo "   - ghcr.io/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | tr '[:upper:]' '[:lower:]')/backend:$VERSION"
    echo "   - ghcr.io/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | tr '[:upper:]' '[:lower:]')/backend:latest"
    echo "   - ghcr.io/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | tr '[:upper:]' '[:lower:]')/frontend:$VERSION"
    echo "   - ghcr.io/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | tr '[:upper:]' '[:lower:]')/frontend:latest"
else
    echo ""
    echo "⏸️  Tag créé localement mais non poussé"
    echo ""
    echo "Pour pousser le tag plus tard:"
    echo "   git push origin $VERSION"
    echo ""
    echo "Pour supprimer le tag local:"
    echo "   git tag -d $VERSION"
fi
