# 🪟 Installer K3s sur Windows

[English version](en/windows.md)

Ce guide s'adresse aux débutants. K3s ne fournit pas de serveur Kubernetes natif Windows. La solution légère est de l'exécuter dans Ubuntu avec WSL2. Les scripts du dépôt sont lancés dans WSL; les interfaces et HeidiSQL restent utilisables depuis Windows via `127.0.0.1`.

## 🚀 Installer WSL2

Dans PowerShell en administrateur :

```powershell
wsl --install -d Ubuntu
```

Redémarrer Windows si demandé, ouvrir Ubuntu et terminer la création de l'utilisateur Linux. Les versions récentes de WSL activent `systemd` par défaut. Le vérifier dans Ubuntu :

```bash
systemctl is-system-running
```

## Installer K3s dans Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y curl git ca-certificates openssl jq docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"
chmod 600 "$HOME/.kube/config"
kubectl config rename-context default k3s-local
kubectl config use-context k3s-local
kubectl cluster-info
```

Fermer puis rouvrir Ubuntu après l'ajout au groupe `docker`. Le moteur Docker tourne directement dans WSL2 et ne nécessite pas Docker Desktop.

Installer Helm dans Ubuntu pour pouvoir ajouter Rancher Web :

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get-helm-3
chmod 700 /tmp/get-helm-3
/tmp/get-helm-3
rm /tmp/get-helm-3
```

Cloner et utiliser le dépôt dans le système de fichiers Linux, par exemple sous `$HOME`, plutôt que sous `/mnt/c` :

```bash
git clone <URL_DU_DEPOT> "$HOME/k8s-local"
cd "$HOME/k8s-local"
./scripts/validate.sh
```

Lancer `./maria/connect.sh` dans Ubuntu permet à HeidiSQL sous Windows d'utiliser `127.0.0.1:3306`. De même, `./vault/connect.sh` rend l'interface disponible dans le navigateur Windows sur `http://127.0.0.1:8200`.

## Installer k9s

Le plus simple est d'installer `k9s` côté Windows. Avec Chocolatey ou Scoop :

```powershell
choco install k9s
# ou
scoop install k9s
```

Copier ensuite le kubeconfig WSL vers Windows depuis PowerShell :

```powershell
New-Item -ItemType Directory -Force "$HOME\.kube" | Out-Null
wsl -d Ubuntu sh -lc 'cat "$HOME/.kube/config"' | Set-Content -Encoding Ascii "$HOME\.kube\config"
k9s --context k3s-local
```

Cette utilisation dépend du transfert automatique de `localhost` fourni par WSL2. Si `k9s` Windows ne joint pas l'API, utiliser l'archive Linux officielle de `k9s` directement dans Ubuntu.

## 🧹 Désinstaller

Dans Ubuntu :

```bash
./reset/reset.sh --all
sudo /usr/local/bin/k3s-uninstall.sh
sudo rm -f /usr/local/bin/helm
rm -f "$HOME/.kube/config"
```

Dans PowerShell, supprimer les outils Windows si besoin :

```powershell
choco uninstall k9s
Remove-Item -Force "$HOME\.kube\config"
```

Pour supprimer aussi toute la distribution Ubuntu et toutes ses données, après avoir sauvegardé les fichiers utiles :

```powershell
wsl --shutdown
wsl --unregister Ubuntu
```