# 🖥️ Rancher Web local

[English version](README-EN.md)

Rancher est une interface Web de gestion Kubernetes. Elle permet de consulter les namespaces, pods, déploiements, logs et autres ressources depuis un navigateur. Ce module installe uniquement **Rancher Web dans K3s** : il n'installe pas l'application Rancher Desktop.

Rancher est plus lourd que `kubectl` ou `k9s`. Il est facultatif et utile lorsque l'on préfère une interface graphique pour découvrir ou inspecter Kubernetes.

## Ce que le module installe

- Rancher `2.15.1` avec le chart Helm officiel ;
- une seule réplique dans le namespace officiel `cattle-system` ;
- aucun Ingress, Traefik ou cert-manager supplémentaire ;
- un mot de passe bootstrap aléatoire dans un Secret Kubernetes ;
- un accès HTTPS limité à `127.0.0.1`.

Prévoir au moins 4 processeurs et 6 Gio de mémoire pour la VM ou la machine K3s locale.

## Prérequis

Vérifier Helm :

```bash
helm version
```

Son installation est expliquée dans les guides [macOS](../docs/macos.md), [Linux](../docs/linux.md) et [Windows](../docs/windows.md).

## 🚀 Installer

```bash
./rancher/deploy.sh
```

Le téléchargement et le premier démarrage peuvent prendre plusieurs minutes. Le chart est épinglé à la version indiquée dans `.env-temp.json`.

## Afficher les identifiants

```bash
./rancher/credentials.sh
```

L'utilisateur initial est `admin`. Le mot de passe affiché sert uniquement à la première connexion; Rancher demande ensuite d'en définir un nouveau.

Si Rancher refuse le mot de passe après une réinstallation, réinitialiser le compte `admin` et resynchroniser les Secrets locaux :

```bash
./rancher/credentials.sh --reset
```

## Ouvrir l'interface

```bash
./rancher/connect.sh
```

Garder le terminal ouvert puis aller sur `https://127.0.0.1.sslip.io:8443`. Le certificat est auto-signé pour le développement local : le navigateur peut afficher un avertissement qu'il faut accepter explicitement.

`Ctrl+C` ferme le tunnel sans arrêter Rancher.

## ⚙️ Personnaliser

```bash
cp rancher/.env-temp.json rancher/.env.json
```

```json
{
	"localPort": 8443,
	"chartVersion": "2.15.1",
	"hostname": "127.0.0.1.sslip.io",
	"replicas": 1
}
```

Le fichier permet de changer le port, la version du chart, le hostname et le nombre de répliques. Vérifier la compatibilité K3s avant de modifier la version Rancher. `.env.json` est ignoré par Git.

## 🧹 Supprimer

```bash
./rancher/delete.sh
```

La release Helm et le namespace Rancher sont supprimés. Les autres modules restent actifs.

## Dépannage

```bash
kubectl get pods -n cattle-system
kubectl logs -n cattle-system deployment/rancher
helm status rancher -n cattle-system
```