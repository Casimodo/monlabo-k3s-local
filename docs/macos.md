# 🍎 Installer K3s sur macOS

[English version](en/macos.md)

Ce guide s'adresse aux débutants. Colima fournit une petite VM Linux et démarre K3s sans Rancher Desktop. Les commandes du dépôt restent exécutées depuis le terminal macOS.

## 🚀 Installer

Installer Homebrew si nécessaire depuis [brew.sh](https://brew.sh), puis :

```bash
brew install colima docker kubectl helm jq derailed/k9s/k9s
colima start --kubernetes --cpus 4 --memory 6 --disk 30
openssl version
```

Colima crée normalement le contexte `colima`. Le renommer pour activer les protections du dépôt :

```bash
kubectl config rename-context colima k3s-local
kubectl config use-context k3s-local
kubectl cluster-info
```

Vérifier que l'API est locale :

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
echo
```

L'adresse doit utiliser `127.0.0.1` ou `localhost`. Tester ensuite le dépôt :

```bash
./scripts/validate.sh
k9s
```

Les commandes `connect.sh` exposent Vault et MariaDB sur le Mac. Un client MariaDB compatible macOS, par exemple DBeaver ou TablePlus, peut utiliser directement `127.0.0.1:3306`. HeidiSQL est un logiciel Windows et n'est pas disponible nativement sur macOS.

## Arrêter et redémarrer

```bash
colima stop
colima start
kubectl config use-context k3s-local
```

## 🧹 Désinstaller

Cette opération détruit tous les workloads et volumes de la VM Colima :

```bash
./reset/reset.sh --all
colima delete --force
kubectl config delete-context k3s-local
kubectl config delete-cluster colima
brew uninstall colima docker kubectl helm jq derailed/k9s/k9s
```

Les deux commandes `kubectl config delete-*` peuvent indiquer que l'entrée n'existe déjà plus, ce qui est sans conséquence.