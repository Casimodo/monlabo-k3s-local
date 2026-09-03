# 🎮 Serveur FiveM local

[English version](README-EN.md)

FiveM est une plateforme multijoueur pour Grand Theft Auto V. Elle permet de créer ses propres modes de jeu et ressources en Lua, JavaScript ou C#. Ce module fournit un serveur FiveM classique isolé pour développer et tester une ressource depuis la machine locale.

## Fonctionnement

FiveM exige TCP et UDP sur le port de jeu. Comme `kubectl port-forward` ne transporte pas UDP, ce module utilise Docker local plutôt que K3s. Les deux protocoles sont publiés uniquement sur `127.0.0.1:30120` et ne sont pas ouverts au réseau local.

Les artefacts Cfx Linux sont x86_64. Sur un Mac Apple Silicon, Docker utilise l'émulation et les performances peuvent être inférieures.

## Préparer l'artefact

1. Ouvrir [la page officielle Server Download](https://docs.fivem.net/docs/server-download/).
2. Copier l'URL de l'artefact Linux FiveM recommandé.
3. Créer la configuration locale :

```bash
cp fivem/.env-temp.json fivem/.env.json
```

4. Remplacer `serverDownloadUrl` dans `.env.json` :

```json
{
	"serverDownloadUrl": "URL_OFFICIELLE_FIVEM_LINUX",
	"localPort": 30120,
	"licenseKey": ""
}
```

La configuration fournie active `sv_lan true` pour des tests locaux sans clé. Une clé Cfx peut être placée dans `licenseKey` lorsque les fonctionnalités du portail l'exigent. `.env.json` est ignoré par Git et ne doit jamais être partagé s'il contient une clé.

## 🚀 Installer et démarrer

```bash
./fivem/deploy.sh
```

Le script construit une image locale depuis l'artefact officiel puis démarre le conteneur.

## Se connecter et voir les logs

```bash
./fivem/connect.sh
```

Dans la console FiveM :

```text
connect 127.0.0.1:30120
```

L'API d'information est disponible sur `http://127.0.0.1:30120/info.json`.

## Développer une ressource

Les fichiers locaux se trouvent dans `fivem/server-data/resources/k8s-local-dev`. Après une modification :

```bash
./fivem/restart.sh
./fivem/connect.sh
```

Le dossier `server-data` est monté directement dans le conteneur : aucune copie manuelle n'est nécessaire.

## 🧹 Supprimer

```bash
./fivem/delete.sh
```

Le conteneur est supprimé, mais les ressources locales sous `server-data` sont conservées.

## Dépannage

```bash
docker ps -a --filter name=k8s-local-fivem
docker logs k8s-local-fivem
```