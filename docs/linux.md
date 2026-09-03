# 💻 Installer K3s sur Linux

[English version](en/linux.md)

Ce guide s'adresse aux débutants et cible une distribution Linux utilisant `systemd`. K3s installe aussi `kubectl` et la StorageClass locale `local-path`.

## 🚀 Installer

```bash
# Debian et Ubuntu
sudo apt-get update
sudo apt-get install -y curl git ca-certificates openssl jq

# Fedora, à utiliser à la place des deux commandes précédentes
sudo dnf install -y curl git ca-certificates openssl jq

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
```

Installer Helm pour pouvoir ajouter Rancher Web :

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3
chmod 700 /tmp/get-helm-3
/tmp/get-helm-3
rm /tmp/get-helm-3
```

Pour utiliser FiveM ou RedM, installer également un moteur Docker local. Sur Debian ou Ubuntu :

```bash
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

Fermer puis rouvrir la session après l'ajout au groupe `docker`. Pour les autres distributions, suivre [l'installation officielle de Docker Engine](https://docs.docker.com/engine/install/).

Traefik est désactivé car MariaDB et Vault utilisent des tunnels locaux et n'ont pas besoin d'un contrôleur Ingress.

Créer un kubeconfig personnel et un contexte explicite :

```bash
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
kubectl config rename-context default k3s-local
kubectl config use-context k3s-local
kubectl cluster-info
```

L'adresse du serveur dans ce fichier doit rester `https://127.0.0.1:6443`.

Installer `k9s` avec le gestionnaire disponible sur la distribution, par exemple :

```bash
# Arch Linux
sudo pacman -S k9s

# Linuxbrew
brew install derailed/k9s/k9s
```

Des archives Linux prêtes à l'emploi sont aussi publiées sur [les releases officielles de k9s](https://github.com/derailed/k9s/releases). Vérifier ensuite :

```bash
./scripts/validate.sh
k9s
```

## 🧹 Désinstaller

Le script officiel supprime K3s, ses workloads, ses volumes et ses données locales :

```bash
./reset/reset.sh --all
sudo /usr/local/bin/k3s-uninstall.sh
sudo rm -f /usr/local/bin/helm
rm -f "$HOME/.kube/config"
```

Supprimer ensuite `k9s` avec le gestionnaire utilisé lors de son installation et effacer le clone du dépôt si vous n'en avez plus besoin.