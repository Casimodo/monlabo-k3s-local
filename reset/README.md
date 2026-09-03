# 🧹 Réinitialiser l'environnement local

[English version](README-EN.md)

Le module Reset nettoie les services de développement créés par ce dépôt. Il évite de supprimer manuellement les namespaces et conteneurs un par un. Deux niveaux de nettoyage sont proposés afin de limiter les suppressions accidentelles.

## ✅ Nettoyage conseillé

```bash
./reset/reset.sh
```

Cette commande supprime :

- les namespaces portant le label `app.kubernetes.io/managed-by=k8s-local` ;
- les conteneurs Docker portant le même label.

Les namespaces système Kubernetes restent présents. Les dossiers locaux comme `server-data` et `nodejs-dev/app` sont conservés.

## ⚠️ Nettoyage complet des ressources utilisateur

```bash
./reset/reset.sh --all
```

Le script demande de saisir exactement `RESET`. Il supprime tous les namespaces utilisateur, vide le namespace `default` et retire les conteneurs Docker gérés par le projet.

Les namespaces protégés sont :

- `default` ;
- `kube-system` ;
- `kube-public` ;
- `kube-node-lease` ;
- `local-path-storage`.

Cette commande peut supprimer des ressources utilisateur qui ne viennent pas de ce dépôt. Vérifier d'abord :

```bash
kubectl get namespaces
```

## Supprimer un seul service

Utiliser de préférence le script `delete.sh` du module concerné, par exemple :

```bash
./maria/delete.sh
./rancher/delete.sh
./fivem/delete.sh
```

## 🗑️ Désinstaller K3s

Reset ne désinstalle pas K3s, Colima, WSL2, Docker, Helm ou `k9s`. Pour retirer toute la plateforme, suivre la section **Désinstaller** du guide [macOS](../docs/macos.md), [Linux](../docs/linux.md) ou [Windows](../docs/windows.md).