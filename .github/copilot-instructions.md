# Contexte du projet k8s-local

Ce dépôt fournit des modules autonomes pour déployer et supprimer des services de développement sur un cluster K3s local.

## Principes

- Chaque service Kubernetes possède son propre dossier avec `deploy.sh`, `connect.sh`, `delete.sh` et un dossier `k8s/`.
- Les scripts doivent pouvoir être lancés depuis leur propre dossier.
- Les scripts shell orchestrent directement les déploiements et suppressions avec `kubectl`.
- Chaque exécution utilise explicitement `${K8S_LOCAL_KUBECONFIG:-$HOME/.kube/config}` et refuse par défaut tout contexte autre que `k3s-local`.
- L'adresse de l'API Kubernetes doit être locale (`127.0.0.1` ou `localhost`); ne jamais permettre une mutation accidentelle d'un cluster distant.
- Tous les namespaces créés par ce projet portent le label `app.kubernetes.io/managed-by=k8s-local`.
- Les accès Kubernetes passent par `kubectl port-forward` et écoutent uniquement sur `127.0.0.1`.
- FiveM et RedM utilisent Docker local, car ils nécessitent UDP; leurs publications TCP/UDP écoutent uniquement sur `127.0.0.1` et refusent un contexte Docker distant.
- Les images doivent être épinglées au minimum à une version majeure/mineure.
- Les identifiants locaux sont générés à la première installation et stockés dans des Secrets Kubernetes.
- Ce projet est réservé au développement local. Ne pas présenter ses réglages comme adaptés à la production.
- Toute nouvelle brique doit suivre la structure existante et être ajoutée au tableau du `README.md`.

## Environnements pris en charge

- Contexte Kubernetes : `k3s-local`
- macOS : K3s via Colima.
- Linux : K3s natif.
- Windows : K3s dans WSL2.
- StorageClass par défaut : `local-path`
- Outils requis : Bash, `kubectl` et OpenSSL.

## Modules actuels

- `maria/` : MariaDB avec volume persistant et accès local pour HeidiSQL.
- `vault/` : HashiCorp Vault en mode développement avec interface web.
- `nodejs-dev/` : serveur Node.js de développement avec Socket.IO et synchronisation locale.
- `rancher/` : interface Rancher Web installée avec le chart Helm officiel, sans Rancher Desktop.
- `fivem/`, `fivem-enhanced/`, `redm/` : profils Cfx Docker locaux avec ressources montées depuis l'hôte.
- `reset/` : nettoyage des modules du projet ou de toutes les ressources utilisateur.
