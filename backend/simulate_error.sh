#!/bin/bash

# Script de simulation d'erreur pour TP4
# Usage: ./simulate_error.sh [enable|disable]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

case "$1" in
    enable)
        echo "🔴 Activation de l'erreur..."
        if [ -f "main.py" ]; then
            mv main.py main_backup.py
            echo "✓ main.py sauvegardé dans main_backup.py"
        fi
        if [ -f "main_avec_erreur.py" ]; then
            cp main_avec_erreur.py main.py
            echo "✓ main_avec_erreur.py copié vers main.py"
            echo ""
            echo "⚠️  ERREUR ACTIVÉE !"
            echo "La route /articles retourne maintenant une erreur 500"
            echo ""
            echo "Pour tester localement:"
            echo "  pytest -v"
            echo ""
            echo "Pour commiter et voir l'échec du CI:"
            echo "  git add ."
            echo "  git commit -m 'test: simulation erreur TP4'"
            echo "  git push"
            echo ""
            echo "Pour désactiver l'erreur:"
            echo "  ./simulate_error.sh disable"
        else
            echo "❌ Erreur: main_avec_erreur.py non trouvé"
            exit 1
        fi
        ;;

    disable)
        echo "🟢 Désactivation de l'erreur..."
        if [ -f "main_backup.py" ]; then
            mv main_backup.py main.py
            echo "✓ main_backup.py restauré vers main.py"
            echo ""
            echo "✅ ERREUR CORRIGÉE !"
            echo "La route /articles retourne maintenant 200"
            echo ""
            echo "Pour tester localement:"
            echo "  pytest -v"
            echo ""
            echo "Pour commiter la correction:"
            echo "  git add ."
            echo "  git commit -m 'fix: correction erreur TP4'"
            echo "  git push"
        else
            echo "⚠️  Aucune sauvegarde trouvée (main_backup.py)"
            echo "L'erreur n'était peut-être pas activée"
        fi
        ;;

    status)
        echo "📊 Statut actuel:"
        echo ""
        if [ -f "main_backup.py" ]; then
            echo "🔴 ERREUR ACTIVÉE"
            echo "  - main_backup.py existe (version correcte sauvegardée)"
            echo "  - main.py contient l'erreur"
        else
            echo "🟢 VERSION NORMALE"
            echo "  - main.py est la version correcte"
        fi
        echo ""
        echo "Fichiers présents:"
        ls -lh main*.py 2>/dev/null || echo "  Aucun fichier main*.py trouvé"
        ;;

    *)
        echo "Usage: $0 [enable|disable|status]"
        echo ""
        echo "Commandes:"
        echo "  enable   - Active l'erreur (main.py retourne 500)"
        echo "  disable  - Désactive l'erreur (main.py retourne 200)"
        echo "  status   - Affiche le statut actuel"
        echo ""
        echo "Exemple de workflow TP4:"
        echo "  1. ./simulate_error.sh enable"
        echo "  2. pytest -v  (observer l'échec)"
        echo "  3. git add . && git commit -m 'test: erreur' && git push"
        echo "  4. Observer l'échec du CI sur GitHub"
        echo "  5. ./simulate_error.sh disable"
        echo "  6. pytest -v  (observer le succès)"
        echo "  7. git add . && git commit -m 'fix: correction' && git push"
        echo "  8. Observer le succès du CI sur GitHub"
        exit 1
        ;;
esac
