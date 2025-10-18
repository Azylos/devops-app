# Utiliser l'image officielle Node.js
FROM node:18-alpine

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install --production

# Copier tout le code source
COPY . .

# Exposer le port 3000
EXPOSE 3000

# Variable d'environnement pour le port
ENV PORT=3000

# Commande pour démarrer l'application
CMD ["npm", "start"]
