# 🎮 Serveur RedM local

[English version](README-EN.md)

RedM est la plateforme multijoueur Cfx pour Red Dead Redemption 2. Elle permet de créer des modes de jeu et ressources personnalisées avec le même écosystème général que FiveM. Ce module fournit un serveur RedM local pour développer et tester des scripts RDR3.

## Fonctionnement

RedM utilise l'artefact FXServer Linux classique avec la commande `gamename rdr3`. Docker publie TCP et UDP uniquement sur `127.0.0.1:30122`, car un tunnel Kubernetes standard ne prend pas en charge UDP.

L'artefact Linux est x86_64. Son exécution sur Apple Silicon utilise donc l'émulation Docker.

## Préparer l'artefact

1. Ouvrir [la page officielle Server Download](https://docs.fivem.net/docs/server-download/).
2. Copier l'URL de l'artefact FXServer Linux recommandé.
3. Créer la configuration locale :

```bash
cp redm/.env-temp.json redm/.env.json
```

4. Renseigner `serverDownloadUrl` :

```json
{
	"serverDownloadUrl": "URL_OFFICIELLE_FXSERVER_LINUX",
	"localPort": 30122,
	"licenseKey": ""
}
```

La configuration active `sv_lan true`. Si une clé Cfx est nécessaire, la placer dans `licenseKey`. `.env.json` est ignoré par Git et ne doit jamais être partagé s'il contient une clé.

## 🚀 Installer et démarrer

```bash
./redm/deploy.sh
```

## Se connecter et voir les logs

```bash
./redm/connect.sh
```

Dans la console RedM :

```text
connect 127.0.0.1:30122
```

L'API d'information est disponible sur `http://127.0.0.1:30122/info.json`.

## Développer une ressource

Modifier les fichiers sous `redm/server-data/resources/k8s-local-dev`, puis :

```bash
./redm/restart.sh
./redm/connect.sh
```

## 🧹 Supprimer

```bash
./redm/delete.sh
```

Les ressources locales sous `server-data` sont conservées.

## Dépannage

```bash
docker ps -a --filter name=k8s-local-redm
docker logs k8s-local-redm
```