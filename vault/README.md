# 🔐 Vault local

[English version](README-EN.md)

HashiCorp Vault est un coffre destiné à centraliser des secrets comme des mots de passe, jetons ou clés d'API. Ce module démarre Vault en mode développement afin de tester son interface Web et son API sans utiliser un service distant.

## Ce que le module installe

- Vault 1.20 dans le namespace `k8s-local-vault` ;
- l'interface Web Vault ;
- un token root aléatoire conservé dans un Secret Kubernetes ;
- un tunnel HTTP limité à `127.0.0.1`.

Le mode développement n'est pas adapté à la production. Les données Vault disparaissent lorsque le pod est recréé.

## 🚀 Installer

```bash
./vault/deploy.sh
```

## Ouvrir l'interface

```bash
./vault/connect.sh
```

Le terminal affiche l'URL `http://127.0.0.1:8200` et le token. Garder le tunnel ouvert, aller sur cette URL, choisir la méthode **Token**, puis saisir le token affiché.

`Ctrl+C` ferme seulement le tunnel.

## Utiliser l'API

L'API utilise la même URL. Par exemple, avec le tunnel ouvert :

```bash
curl http://127.0.0.1:8200/v1/sys/health
```

## ⚙️ Configurer

Copier le modèle puis modifier le port si nécessaire :

```bash
cp vault/.env-temp.json vault/.env.json
```

```json
{
	"localPort": 8200
}
```

Le fichier `.env.json` est ignoré par Git.

Pour une modification ponctuelle, la variable d'environnement reste disponible :

```bash
VAULT_LOCAL_PORT=8201 ./vault/connect.sh
```

## 🧹 Supprimer

```bash
./vault/delete.sh
```

Le namespace et toutes les données temporaires Vault sont supprimés.

## Dépannage

```bash
kubectl get pods -n k8s-local-vault
kubectl logs -n k8s-local-vault deployment/vault
```