# Mises à jour

Ce journal recense les modifications majeures et les corrections significatives du projet.

## 2026-10-21 14:27 CEST

### Corrections

- Préparation de la release corrective `1.0.2` : mise à jour de `VERSION` et des notes de publication pour les garde-fous du pod MariaDB et son stockage éphémère.

## 2026-10-21 14:20 CEST

### Corrections

- Désactivation du montage automatique du jeton de compte de service du pod MariaDB, qui n'utilise pas l'API Kubernetes.
- Ajout d'une demande de stockage éphémère de `128Mi` et d'une limite de `1Gi` au conteneur MariaDB, sans modifier son volume persistant de `5Gi`.

## 2026-10-21 14:15 CEST

### Corrections

- Migration des jobs de validation et de publication GitHub vers `actions/checkout@v5`, compatible avec Node.js 24, pour supprimer l'avertissement de dépréciation de Node.js 20 sans modifier les options de récupération et d'authentification.
- Préparation de la release corrective `1.0.1` avec sa version et ses notes de publication.

## 2026-10-21 14:02 CEST

### Modifications majeures

- Préparation de la première release `1.0.0` avec le fichier `VERSION` et les notes `RELEASE.md`, couvrant les services locaux, les garde-fous et le parcours de publication GitHub.

## 2026-10-21 13:51 CEST

### Modifications majeures

- Ajout de Gitleaks en pre-commit et dans les CI GitLab et GitHub pour bloquer les secrets détectés, sans job Sonar.
- Intégration du contrôle des fichiers indexés dans `/commit`, sans commit ni push automatique.
- Ajout du skill `/release X.Y.Z` pour préparer la version et les notes avant `/commit`, puis publier le tag et la release GitHub après validation du push sur la branche par défaut.

## 2026-10-21 11:40 CEST

### Modifications majeures

- Ajout du skill `/commit` pour synchroniser prudemment la branche, contrôler les différences, tenir ce journal à jour et préparer un message Conventional Commits en français.

### Corrections

- Ajout d'un rappel de démarrage de Colima dans les parcours macOS et Vault afin d'éviter de confondre un cluster arrêté avec une dépendance entre modules.
- Clarification de l'autonomie du module Vault, qui ne nécessite aucun autre service du dépôt.