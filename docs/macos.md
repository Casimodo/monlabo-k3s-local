# 🍎 Installer K3s sur macOS

[English version](en/macos.md)

Ce guide s'adresse aux débutants. Colima fournit une petite VM Linux et démarre K3s sans Rancher Desktop. Les commandes du dépôt restent exécutées depuis le terminal macOS.

## 🚀 Installer

Installer Homebrew si nécessaire depuis [brew.sh](https://brew.sh), puis :

```bash
brew install colima docker kubectl helm jq derailed/k9s/k9s
unalias kubectl 2>/dev/null || true
unset -f kubectl 2>/dev/null || true
hash -r
command -v kubectl
kubectl version --client
openssl version
```

La commande `command -v kubectl` doit afficher `/opt/homebrew/bin/kubectl` sur un Mac Apple Silicon ou `/usr/local/bin/kubectl` sur un Mac Intel. Elle ne doit pas afficher un chemin contenant `.rd/bin`, qui appartient à Rancher Desktop.

### Si `kubectl` pointe encore vers `.rd/bin`

Rechercher l'ancienne configuration Rancher Desktop :

```bash
grep -nH -E '\.rd/bin|alias kubectl' ~/.bash_profile ~/.bashrc ~/.profile ~/.zprofile ~/.zshrc 2>/dev/null || true
```

Ouvrir chaque fichier indiqué, supprimer la ligne qui contient `.rd/bin` ou l'ancien alias `kubectl`, puis fermer et rouvrir le terminal. Reprendre ensuite le guide à la commande `brew install`. Ne pas continuer tant que `command -v kubectl` pointe vers `.rd/bin`.

Démarrer ensuite K3s :

```bash
colima start --kubernetes --cpus 4 --memory 6 --disk 30
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