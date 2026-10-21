# v1.0.1

## Corrections

- Migration de `actions/checkout@v4` vers `actions/checkout@v5` dans les jobs de validation et de publication GitHub pour utiliser Node.js 24 et supprimer l'avertissement de deprecation de Node.js 20.
- Conservation de la recuperation de l'historique complet (`fetch-depth: 0`) et de la desactivation de la persistance des identifiants (`persist-credentials: false`).
