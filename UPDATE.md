# Mises à jour

Ce journal recense les modifications majeures et les corrections significatives du projet.

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