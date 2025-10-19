#!/bin/bash
# Script de démarrage pour image Docker multi-services
# Lance PostgreSQL + Backend FastAPI + Frontend Node.js

set -e

echo "========================================="
echo "🚀 Démarrage de l'application DevOps"
echo "========================================="

# === ÉTAPE 1 : Démarrage PostgreSQL ===
echo "📦 [1/4] Démarrage PostgreSQL..."
su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/data -l /var/log/postgresql.log start"

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
until su - postgres -c "pg_isready -U devops_user" > /dev/null 2>&1; do
    sleep 1
done
echo "✅ PostgreSQL démarré"

# === ÉTAPE 2 : Initialisation de la base de données ===
echo "📦 [2/4] Initialisation de la base de données..."
su - postgres -c "psql -lqt | cut -d \| -f 1 | grep -qw devops_db" || {
    su - postgres -c "createdb devops_db"
    su - postgres -c "psql -d devops_db -c \"CREATE USER devops_user WITH PASSWORD 'devops_password';\""
    su - postgres -c "psql -d devops_db -c \"GRANT ALL PRIVILEGES ON DATABASE devops_db TO devops_user;\""
    su - postgres -c "psql -d devops_db -f /app/init.sql"
    echo "✅ Base de données initialisée"
}

# === ÉTAPE 3 : Démarrage du Backend FastAPI ===
echo "📦 [3/4] Démarrage du backend FastAPI (port $BACKEND_PORT)..."
cd /app/backend
uvicorn main:app --host 0.0.0.0 --port $BACKEND_PORT &
BACKEND_PID=$!
echo "✅ Backend démarré (PID: $BACKEND_PID)"

# Attendre que le backend soit prêt
echo "⏳ Attente du backend..."
until curl -sf http://localhost:$BACKEND_PORT/ > /dev/null 2>&1; do
    sleep 1
done
echo "✅ Backend prêt"

# === ÉTAPE 4 : Démarrage du Frontend Node.js ===
echo "📦 [4/4] Démarrage du frontend Node.js (port $PORT)..."
cd /app/frontend

# Modifier le port du frontend
export PORT=$PORT

# Démarrer le frontend
npm start &
FRONTEND_PID=$!
echo "✅ Frontend démarré (PID: $FRONTEND_PID)"

# Attendre que le frontend soit prêt
echo "⏳ Attente du frontend..."
sleep 5
until curl -sf http://localhost:$PORT/ > /dev/null 2>&1; do
    sleep 1
done

echo "========================================="
echo "✅ Application démarrée avec succès !"
echo "========================================="
echo "📊 Services actifs :"
echo "  - Frontend:   http://localhost:$PORT"
echo "  - Backend:    http://localhost:$BACKEND_PORT"
echo "  - PostgreSQL: localhost:5432"
echo "========================================="

# Fonction de cleanup à l'arrêt
cleanup() {
    echo ""
    echo "🛑 Arrêt des services..."
    kill $FRONTEND_PID 2>/dev/null || true
    kill $BACKEND_PID 2>/dev/null || true
    su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D /var/lib/postgresql/data stop"
    echo "✅ Services arrêtés"
    exit 0
}

# Capturer les signaux d'arrêt
trap cleanup SIGTERM SIGINT

# Garder le script en vie et surveiller les processus
while true; do
    # Vérifier que tous les services sont toujours en vie
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo "❌ Backend arrêté inopinément, redémarrage..."
        cd /app/backend
        uvicorn main:app --host 0.0.0.0 --port $BACKEND_PORT &
        BACKEND_PID=$!
    fi

    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo "❌ Frontend arrêté inopinément, redémarrage..."
        cd /app/frontend
        npm start &
        FRONTEND_PID=$!
    fi

    sleep 10
done
