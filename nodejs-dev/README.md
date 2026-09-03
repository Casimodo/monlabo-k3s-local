# ⚡ Serveur Node.js temps réel

[English version](README-EN.md)

Node.js exécute du JavaScript côté serveur. Socket.IO ajoute des échanges bidirectionnels en temps réel entre le navigateur et le serveur, utiles pour un chat, des notifications ou un tableau de bord vivant. Ce module fournit un petit site prêt à modifier avec rechargement automatique.

## Ce que le module installe

- Node.js 22 dans le namespace `k8s-local-nodejs-dev` ;
- Express, Socket.IO et `nodemon` ;
- un exemple qui affiche le nombre de navigateurs connectés ;
- une copie synchronisable du dossier local `nodejs-dev/app` ;
- un tunnel Web limité à `127.0.0.1`.

## 🚀 Installer

```bash
./nodejs-dev/deploy.sh
```

## Ouvrir le site

```bash
./nodejs-dev/connect.sh
```

Garder le terminal ouvert, puis aller sur `http://127.0.0.1:3000`.

## Développer

Le code source se trouve dans `nodejs-dev/app`. Dans un deuxième terminal, surveiller et synchroniser les modifications :

```bash
./nodejs-dev/sync.sh --watch
```

Après un changement, les fichiers sont copiés dans le pod et `nodemon` redémarre Node.js. Arrêter la surveillance avec `Ctrl+C`.

Pour effectuer une seule synchronisation :

```bash
./nodejs-dev/sync.sh
```

## ⚙️ Configurer

Copier le modèle de configuration :

```bash
cp nodejs-dev/.env-temp.json nodejs-dev/.env.json
```

```json
{
	"localPort": 3000,
	"syncIntervalSeconds": 2
}
```

`localPort` définit le port du site sur la machine. `syncIntervalSeconds` définit la fréquence de détection des modifications. Le fichier `.env.json` est ignoré par Git.

Une variable d'environnement peut encore surcharger ponctuellement le JSON :

```bash
NODEJS_LOCAL_PORT=3001 ./nodejs-dev/connect.sh
```

## 🧹 Supprimer

```bash
./nodejs-dev/delete.sh
```

Le code du dossier local `app` est conservé.

## Dépannage

```bash
kubectl get pods -n k8s-local-nodejs-dev
kubectl logs -n k8s-local-nodejs-dev deployment/nodejs-dev
```