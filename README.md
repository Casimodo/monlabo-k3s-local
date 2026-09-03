# 🧰 k8s-local

[English version](README-EN.md)

`k8s-local` fournit des services prêts à lancer pour développer et tester sur sa propre machine. Les services Web et de données tournent dans un cluster K3s local. FiveM et RedM utilisent Docker local, car leurs clients ont besoin du protocole UDP.

Ce projet est réservé au développement local. Les accès sont liés à `127.0.0.1` et les réglages proposés ne sont pas adaptés à la production.

## 🌱 Pour les débutants

Kubernetes est un système qui démarre, surveille et organise des applications conteneurisées. Une application est décrite par des fichiers YAML appelés *manifests*. Kubernetes crée ensuite les conteneurs, leur réseau et leur stockage de façon reproductible.

K3s est une distribution Kubernetes plus légère, adaptée à une machine de développement. Ce dépôt masque volontairement une grande partie de sa complexité derrière des scripts simples : installer une ressource, ouvrir un accès local, puis la supprimer.

L'objectif est d'obtenir un environnement de développement isolé pour tester une base SQL, une API, un site temps réel ou une interface Kubernetes sans utiliser de serveur distant.

## 🚀 Commencer

Installer K3s et les outils en suivant le guide du système utilisé :

- [macOS avec Colima](docs/macos.md)
- [Linux avec K3s natif](docs/linux.md)
- [Windows avec K3s dans WSL2](docs/windows.md)

Les scripts attendent un contexte Kubernetes nommé `k3s-local` et refusent une API qui ne répond pas sur `127.0.0.1` ou `localhost`.

Vérifier ensuite l'environnement :

```bash
./scripts/validate.sh
```

## 📚 Documentation

### Installer la plateforme

| Système | Installation et désinstallation |
| --- | --- |
| macOS | [K3s avec Colima](docs/macos.md) |
| Linux | [K3s natif](docs/linux.md) |
| Windows | [K3s dans WSL2](docs/windows.md) |

### Utiliser une ressource

| Ressource | Documentation |
| --- | --- |
| MariaDB | [Base de données locale](maria/README.md) |
| Vault | [Coffre de secrets local](vault/README.md) |
| Node.js | [Site temps réel](nodejs-dev/README.md) |
| Rancher Web | [Interface Kubernetes](rancher/README.md) |
| FiveM | [Serveur GTA V classique](fivem/README.md) |
| FiveM Enhanced | [Serveur GTA V Enhanced](fivem-enhanced/README.md) |
| RedM | [Serveur Red Dead Redemption 2](redm/README.md) |
| Reset | [Nettoyage de l'environnement](reset/README.md) |

## 🗂️ Arborescence

```text
k8s-local/
├── README.md              Accueil et index en français
├── README-EN.md           Accueil et index en anglais
├── docs/                  Guides système en français
│   └── en/                Guides système en anglais
├── scripts/               Fonctions communes, validation et runtime Cfx
├── maria/                 Base de données MariaDB et volume persistant
│   └── k8s/               Manifests Kubernetes du module
├── vault/                 Coffre de secrets Vault en mode développement
│   └── k8s/               Manifests Kubernetes du module
├── nodejs-dev/            Site Node.js, Socket.IO et synchronisation du code
│   ├── app/               Code source local à modifier
│   └── k8s/               Manifests Kubernetes du module
├── rancher/               Interface Web Rancher installée avec Helm
├── fivem/                 Serveur FiveM classique et ressources locales
│   └── server-data/       Configuration et scripts de jeu à modifier
├── fivem-enhanced/        Serveur pour GTA V Enhanced
│   └── server-data/       Configuration et scripts Enhanced
├── redm/                  Serveur RedM pour Red Dead Redemption 2
│   └── server-data/       Configuration et scripts RedM
└── reset/                 Nettoyage sélectif ou complet de l'environnement
```

Chaque dossier de ressource est autonome. Il contient ses commandes et son propre README :

- `deploy.sh` installe ou met à jour la ressource ;
- `connect.sh` ouvre l'accès local ou affiche les logs ;
- `delete.sh` supprime la ressource ;
- `.env-temp.json` présente les paramètres des services configurables ;
- `README.md` explique l'outil pas à pas en français ;
- `README-EN.md` fournit le même guide en anglais.

Le module `reset` n'a pas de configuration persistante : son option destructive `--all` exige toujours une confirmation manuelle.

## 📦 Ressources

| Ressource | Usage | Accès local | Documentation |
| --- | --- | --- | --- |
| MariaDB | Base SQL compatible MySQL | `127.0.0.1:3306` | [Guide MariaDB](maria/README.md) |
| Vault | Secrets, tokens et API Vault | `http://127.0.0.1:8200` | [Guide Vault](vault/README.md) |
| Node.js | Site temps réel avec Socket.IO | `http://127.0.0.1:3000` | [Guide Node.js](nodejs-dev/README.md) |
| Rancher Web | Interface de gestion Kubernetes | `https://127.0.0.1.sslip.io:8443` | [Guide Rancher](rancher/README.md) |
| FiveM | Développement GTA V classique | TCP/UDP `127.0.0.1:30120` | [Guide FiveM](fivem/README.md) |
| FiveM Enhanced | Développement GTA V Enhanced | TCP/UDP `127.0.0.1:30121` | [Guide FiveM Enhanced](fivem-enhanced/README.md) |
| RedM | Développement Red Dead Redemption 2 | TCP/UDP `127.0.0.1:30122` | [Guide RedM](redm/README.md) |
| Reset | Nettoyage de l'environnement | sans objet | [Guide Reset](reset/README.md) |

## ⚙️ Configuration JSON

Une ressource fonctionne avec ses valeurs par défaut sans créer de configuration. Pour la personnaliser, copier son modèle :

```bash
cp maria/.env-temp.json maria/.env.json
```

Modifier ensuite `.env.json` avec un éditeur. Le modèle contient uniquement du JSON simple :

```json
{
  "database": "app",
  "user": "app",
  "localPort": 3306
}
```

Le fichier `.env.json` est ignoré par Git. Il peut contenir une clé locale et ne doit pas être partagé. Les variables d'environnement restent prioritaires pour une surcharge ponctuelle.

## 🧹 Tout désinstaller proprement

La suppression se fait en deux étapes :

1. [Reset](reset/README.md) retire les services, namespaces, volumes et conteneurs créés pour les tests.
2. Le guide du système retire ensuite K3s, Colima ou WSL2, Docker, Helm, `kubectl`, `k9s` et les fichiers de configuration concernés.

Commencer par :

```bash
./reset/reset.sh --all
```

Suivre ensuite la section **Désinstaller** du guide [macOS](docs/macos.md), [Linux](docs/linux.md) ou [Windows](docs/windows.md). Les commandes y sont détaillées pour ne pas laisser de cluster, volume ou configuration locale inutile.

## 🔒 Sécurité locale

Avant toute opération Kubernetes, les scripts vérifient :

- le fichier kubeconfig explicite ;
- le contexte `k3s-local` ;
- une adresse d'API Kubernetes locale ;
- l'accès effectif au cluster.

Les modules Cfx refusent également un contexte Docker distant. Tous les tunnels et ports publiés écoutent uniquement sur `127.0.0.1`.