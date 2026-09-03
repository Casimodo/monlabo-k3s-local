# 🎮 Serveur FiveM Enhanced local

[English version](README-EN.md)

FiveM pour GTA V Enhanced cible l'édition Enhanced de Grand Theft Auto V. Il utilise un artefact serveur distinct et propose des fonctions spécifiques, notamment un mode de développement. Ce module permet de tester localement des ressources destinées à cette édition sans mélanger leur configuration avec FiveM classique.

## Fonctionnement

Le serveur utilise Docker local afin de publier TCP et UDP uniquement sur `127.0.0.1:30121`. La configuration active `sv_devMode true`, OneSync et limite le serveur à huit clients pour le développement.

L'artefact Enhanced Linux est x86_64. Sur Apple Silicon, son exécution repose sur l'émulation Docker et peut être plus lente.

## Préparer l'artefact Enhanced

1. Ouvrir [la page officielle Server Download](https://docs.fivem.net/docs/server-download/).
2. Copier l'URL de l'artefact Linux **GTA V Enhanced**, différent de l'artefact FiveM classique.
3. Créer le fichier local :

```bash
cp fivem-enhanced/.env-temp.json fivem-enhanced/.env.json
```

4. Renseigner `serverDownloadUrl` dans ce fichier :

```json
{
	"serverDownloadUrl": "URL_OFFICIELLE_FIVEM_ENHANCED_LINUX",
	"localPort": 30121,
	"licenseKey": ""
}
```

Le serveur utilise `sv_lan true`. Une éventuelle clé Cfx se place dans `licenseKey`. `.env.json` est ignoré par Git et ne doit jamais être partagé s'il contient une clé.

## 🚀 Installer et démarrer

```bash
./fivem-enhanced/deploy.sh
```

## Se connecter et voir les logs

```bash
./fivem-enhanced/connect.sh
```

Dans la console du client GTA V Enhanced :

```text
connect 127.0.0.1:30121
```

L'API d'information est disponible sur `http://127.0.0.1:30121/info.json`.

## Développer une ressource

Modifier les fichiers sous `fivem-enhanced/server-data/resources/k8s-local-dev`, puis :

```bash
./fivem-enhanced/restart.sh
./fivem-enhanced/connect.sh
```

## 🧹 Supprimer

```bash
./fivem-enhanced/delete.sh
```

Le dossier local `server-data` est conservé.

## Dépannage

```bash
docker ps -a --filter name=k8s-local-fivem-enhanced
docker logs k8s-local-fivem-enhanced
```