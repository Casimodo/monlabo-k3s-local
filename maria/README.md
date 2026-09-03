# 🗄️ MariaDB locale

[English version](README-EN.md)

MariaDB est un système de gestion de base de données relationnelle compatible avec MySQL. Il sert à stocker les données structurées d'une application et à exécuter des requêtes SQL. Ce module fournit une base jetable pour développer et tester localement sans toucher à une base distante.

## Ce que le module installe

- MariaDB 11.4 dans le namespace `k8s-local-maria` ;
- un volume persistant de 5 Gio ;
- une base et un utilisateur de développement ;
- des mots de passe aléatoires conservés dans un Secret Kubernetes ;
- un tunnel SQL limité à `127.0.0.1`.

## 🚀 Installer

Depuis la racine du dépôt :

```bash
./maria/deploy.sh
```

Le premier démarrage peut prendre quelques minutes pour télécharger l'image. Le script peut être relancé : il conserve le volume et les identifiants existants.

## Afficher les identifiants

```bash
./maria/credentials.sh
```

Le terminal affiche la base, l'utilisateur et les mots de passe. Ne pas partager ces valeurs ni les placer dans Git.

## Se connecter

Ouvrir le tunnel et laisser le terminal actif :

```bash
./maria/connect.sh
```

Configurer HeidiSQL, DBeaver ou un autre client SQL :

| Champ | Valeur |
| --- | --- |
| Type | MariaDB ou MySQL TCP/IP |
| Hôte | `127.0.0.1` |
| Port | `3306` |
| Base | valeur de `credentials.sh` |
| Utilisateur | valeur de `credentials.sh` |
| Mot de passe | valeur de `credentials.sh` |

`Ctrl+C` ferme seulement le tunnel. MariaDB continue de fonctionner dans K3s.

## ⚙️ Personnaliser

Le fichier `.env-temp.json` présente toutes les valeurs configurables. Le copier avant le premier déploiement :

```bash
cp maria/.env-temp.json maria/.env.json
```

Modifier ensuite `.env.json` :

```json
{
	"database": "app",
	"user": "app",
	"localPort": 3306
}
```

Le fichier `.env.json` reste local et n'est pas ajouté à Git. Un changement de base ou d'utilisateur après la création du Secret nécessite de supprimer puis recréer le module.

## 🧹 Supprimer

```bash
./maria/delete.sh
```

Cette commande supprime le namespace et le volume. Toutes les données MariaDB sont perdues.

## Dépannage

Si le port 3306 est déjà occupé, changer `localPort` dans `.env.json`.

Pour examiner le pod :

```bash
kubectl get pods -n k8s-local-maria
kubectl logs -n k8s-local-maria deployment/mariadb
```