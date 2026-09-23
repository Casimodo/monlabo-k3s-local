# AI Generation Lab

[English version](README-EN.md)

Ce module génère des images localement avec le GPU Apple Silicon. Son API et son interface Web tournent directement sous macOS, hors de K3s et Colima, afin que MLX utilise Metal. Aucun prompt ni résultat n'est envoyé à une API d'IA distante.

> Ce module est un laboratoire local, pas une configuration de production.

## Ce que le module installe

- une API FastAPI liée uniquement à `127.0.0.1` ;
- une interface Web et une galerie locale ;
- MFLUX 0.20 avec `Tongyi-MAI/Z-Image-Turbo` quantifié en 8 bits ;
- une file locale avec une seule génération simultanée par défaut ;
- un environnement Python isolé dans `.venv`.

Le modèle est téléchargé depuis Hugging Face lors de la première génération, puis l'inférence fonctionne localement. La génération vidéo reste désactivée tant qu'un moteur fiable n'a pas été validé sur cette machine.

## 1. Installation

Prérequis : un Mac Apple Silicon, macOS, Python 3.10 ou supérieur et une connexion Internet pour l'installation initiale.

```bash
cd ai-generation
./deploy.sh
```

Le script vérifie macOS et Apple Silicon, crée `.venv`, installe les dépendances et démarre le serveur. Il ne télécharge pas immédiatement les poids du modèle.

## 2. Premier démarrage

Ouvrir l'interface :

```bash
./connect.sh
```

Adresses par défaut :

- Web : `http://127.0.0.1:8180`
- API : `http://127.0.0.1:8180/api`
- Santé : `http://127.0.0.1:8180/api/health`

## 3. Première génération

1. Saisir un prompt dans l'onglet **IMAGE**.
2. Garder `1024 × 1024`, 9 étapes et un seed vide pour commencer.
3. Cliquer sur **Générer l'image**.
4. Attendre le téléchargement initial du modèle, puis la génération.

Z-Image-Turbo n'utilise pas de negative prompt : ce champ est volontairement désactivé.

L'API fonctionne de façon asynchrone : `POST /api/images/generate` retourne un identifiant, puis `GET /api/jobs/{id}` expose `queued`, `running`, `completed` ou `failed`.

## 4. Où trouver les images

Les PNG et leurs métadonnées JSON restent dans :

```text
outputs/images/
```

Ils ne sont pas supprimés par un arrêt normal et ne sont jamais stockés en base64.

## 5. Changer de modèle

Copier la configuration modèle :

```bash
cp .env-temp.json .env.json
```

Le seul modèle exposé actuellement est `Tongyi-MAI/Z-Image-Turbo`. L'abstraction interne permet d'ajouter d'autres providers, mais un nom arbitraire est refusé tant qu'il n'est pas validé et déclaré dans l'API.

Réglages utiles :

```json
{
  "host": "127.0.0.1",
  "port": 8180,
  "imageModel": "Tongyi-MAI/Z-Image-Turbo",
  "imageQuantization": 8,
  "maxConcurrentJobs": 1,
  "outputsDirectory": "./outputs",
  "keepModelLoaded": true
}
```

Seuls `127.0.0.1` et `localhost` sont acceptés. Les dimensions d'image doivent être comprises entre 256 et 2048 et être des multiples de 16.

## 6. Arrêter le moteur

```bash
./delete.sh
```

Cette commande arrête le serveur et conserve `.venv`, le cache des modèles et les générations.

## 7. Redémarrer

```bash
./deploy.sh
```

Les dépendances déjà installées et le modèle en cache sont réutilisés.

## 8. Désinstaller

Pour supprimer également l'environnement Python et toutes les sorties :

```bash
./delete.sh --all
```

La commande demande de saisir `DELETE` avant toute suppression des générations. Le cache Hugging Face global de macOS n'est pas supprimé automatiquement.

## 9. Résoudre les problèmes courants

Consulter le journal :

```bash
tail -f .runtime/server.log
```

- **Premier rendu lent** : le modèle est téléchargé une seule fois.
- **Mémoire insuffisante** : fermer les applications lourdes et réduire les dimensions ; conserver la quantification 8 bits et `maxConcurrentJobs` à 1.
- **Port occupé** : modifier `port` dans `.env.json`, puis relancer `./deploy.sh`.
- **Serveur déjà lancé** : `./delete.sh`, puis `./deploy.sh`.
- **Erreur Hugging Face** : vérifier la connexion initiale et l'espace disque disponible.

## API REST

| Méthode | Route | Rôle |
| --- | --- | --- |
| GET | `/api/health` | État du serveur |
| GET | `/api/models` | Modèles et capacités |
| POST | `/api/images/generate` | Créer un job image |
| GET | `/api/jobs/{id}` | Suivre un job |
| GET | `/api/images` | Lister les images |
| GET | `/api/images/{id}` | Lire les métadonnées |
| POST | `/api/videos/generate` | Retourne 501 tant que désactivé |
| GET | `/api/videos` | Lister les vidéos |
| GET | `/api/videos/{id}` | Lire les métadonnées vidéo |

Une application dans K3s ne peut pas utiliser `127.0.0.1` pour joindre le Mac : cette adresse désigne alors le pod. Une intégration future devra employer une route hôte fournie explicitement par Colima ou un proxy local dédié. Ce module ne modifie volontairement pas le réseau global du laboratoire.

## Tests

```bash
.venv/bin/python -m pytest -q
```

Les tests utilisent un faux provider et ne téléchargent aucun modèle.