---
name: release
description: "Prépare une release numérotée avant /commit. Utiliser /release X.Y.Z pour mettre à jour VERSION et RELEASE.md ; GitHub Actions crée ensuite le tag et la release après validation du push sur la branche par défaut."
argument-hint: "X.Y.Z"
user-invocable: true
disable-model-invocation: true
---

# Préparer une release

Préparer les fichiers de version sans créer de commit, de tag, de push ou de release distante. La publication est réservée au workflow GitHub après validation.

## Procédure

1. Lire `git status --short --branch`, `VERSION`, `RELEASE.md` s'ils existent, `UPDATE.md` et les différences pertinentes. Préserver tous les changements existants. Refuser un detached HEAD ou des conflits non résolus.
2. Demander le numéro s'il manque. Accepter uniquement `X.Y.Z` avec trois entiers sans zéro initial (sauf `0`), sans préfixe `v`. Ne pas deviner une version et ne pas utiliser la version propre au module Node.js.
3. Exécuter `git fetch --tags` si un remote existe. En cas d'échec, arrêter et expliquer que les tags distants n'ont pas pu être vérifiés. Refuser un tag `vX.Y.Z` déjà existant. Vérifier que la version est strictement supérieure aux versions stables déjà publiées et à `VERSION`, sauf si cette même version est déjà en cours de préparation et n'a pas de tag.
4. Créer ou mettre à jour `VERSION` à la racine : une seule ligne `X.Y.Z`. Ne modifier aucune version de module autonome.
5. Créer ou remplacer `RELEASE.md` à la racine avec un titre `# vX.Y.Z` et des notes françaises concises décrivant uniquement les changements réels depuis la dernière release. Pour la première release, décrire le périmètre actuel. S'appuyer sur les différences, l'historique Git et `UPDATE.md`, sans inventer de changements. Ne jamais inclure de secret.
6. Valider `VERSION` avec `bash scripts/check-release.sh` et exécuter `git diff --check`. Corriger tout échec avant de poursuivre.
7. Indiquer les fichiers préparés et inviter à lancer `/commit` pour mettre à jour le journal, indexer explicitement le lot et passer Gitleaks et les validations ciblées. Ne jamais affirmer que la release est déjà publiée.

## Publication

Après le commit et un push sur la branche GitHub par défaut, `.github/workflows/release.yml` vérifie les secrets de tout l'historique et les fichiers de release. Le job de publication crée le tag `vX.Y.Z` sur le commit contrôlé puis la release avec `RELEASE.md`. Un tag existant sur un autre commit bloque la publication. Un push sur une autre branche ou une pull request ne publie rien.