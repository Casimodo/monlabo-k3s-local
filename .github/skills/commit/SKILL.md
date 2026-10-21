---
name: commit
description: "Prépare un commit Git propre sans l'exécuter. Utiliser avec /commit pour synchroniser la branche, examiner les différences, mettre à jour UPDATE.md, valider les changements et proposer une commande git commit -m en français conforme à Conventional Commits."
argument-hint: "[périmètre ou intention du commit]"
user-invocable: true
disable-model-invocation: true
---

# Préparer un commit

Ce workflow synchronise prudemment la branche, contrôle les changements à inclure, tient le journal du projet à jour et prépare un message de commit. Il ne crée jamais le commit et ne pousse jamais la branche.

## Règles de sécurité

- Ne jamais exécuter `git reset --hard`, `git checkout --`, `git clean`, un push forcé ou une autre commande destructive.
- Ne jamais supprimer, écraser, stasher ou inclure silencieusement des changements existants.
- Ne jamais ajouter de secret, jeton, mot de passe, kubeconfig ou fichier d'environnement au commit.
- Ne pas mélanger des changements sans rapport. Signaler les fichiers hors périmètre et les laisser intacts.
- En cas de conflit ou d'état Git ambigu, arrêter les mutations et expliquer précisément la résolution attendue.

## Procédure

### 1. Examiner le dépôt

1. Exécuter `git status --short --branch`.
2. Identifier la branche active et son upstream avec `git rev-parse --abbrev-ref HEAD` et `git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'`.
3. Refuser de travailler en detached HEAD. Si aucun upstream n'est configuré, l'indiquer et demander sa configuration avant le pull.
4. Noter tous les fichiers modifiés, indexés et non suivis. Ne rien modifier à cette étape.

### 2. Synchroniser la branche

1. Exécuter `git fetch --prune`.
2. Comparer la branche et son upstream avec `git rev-list --left-right --count HEAD...'@{upstream}'`.
3. Si l'arbre de travail est propre, exécuter `git pull --ff-only`.
4. Si des changements locaux existent et que l'upstream n'est pas en avance, exécuter `git pull --ff-only`; la commande doit être sans effet sur les changements locaux.
5. Si des changements locaux existent et que l'upstream est en avance, ne pas lancer un pull susceptible de les écraser. Présenter l'état au demandeur et obtenir son accord avant toute stratégie explicite de stash ou de rebase.
6. Si les branches ont divergé, arrêter le workflow et expliquer les commits locaux et distants concernés. Ne jamais choisir automatiquement merge, rebase ou reset.

### 3. Vérifier les différences

1. Relire l'état avec `git status --short`.
2. Examiner `git diff --stat`, `git diff`, `git diff --cached --stat` et `git diff --cached`.
3. Lire le contenu pertinent des fichiers non suivis avant de les considérer dans le périmètre.
4. Résumer les changements fonctionnels, les corrections, les tests et les éventuels fichiers hors périmètre.
5. Rechercher les secrets ou données locales accidentellement présents. En cas de doute, arrêter et les signaler.

### 4. Mettre à jour UPDATE.md

Créer `UPDATE.md` à la racine s'il n'existe pas. S'il existe, conserver son historique et son style, puis ajouter l'entrée la plus récente en haut.

Utiliser la date et l'heure locales retournées par `date '+%Y-%m-%d %H:%M %Z'`. Ne journaliser que les modifications importantes et les corrections qui changent réellement le comportement, l'usage, l'architecture ou la maintenance du projet. Ne pas ajouter d'entrée pour du formatage isolé ou une modification triviale.

Format par défaut :

```markdown
## AAAA-MM-JJ HH:MM ZONE

### Modifications majeures

- Description concise orientée utilisateur ou maintenance.

### Corrections

- Description concise du problème corrigé et de son effet.
```

Omettre une sous-section vide. Regrouper dans une même entrée les changements appartenant au même lot et éviter les doublons lors d'une nouvelle exécution de `/commit`.

### 5. Valider le lot

1. Exécuter `git diff --check`.
2. Lancer les tests ou validations les plus ciblés disponibles pour les fichiers concernés.
3. Réexaminer le diff après la mise à jour de `UPDATE.md`.
4. Ne pas indexer automatiquement les fichiers sauf demande explicite. Distinguer clairement les changements indexés et non indexés.

### 6. Préparer le message français

Produire un message conforme à Conventional Commits :

```text
type(scope facultatif): description en français
```

Choisir le type parmi `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `ci`, `build`, `perf` ou `revert`. Utiliser une description brève, précise, à l'infinitif, sans point final et idéalement limitée à 72 caractères avec le préfixe.

Terminer par :

1. un résumé des fichiers et changements retenus ;
2. le résultat du pull et des validations ;
3. les changements volontairement exclus ou les blocages ;
4. une commande directement copiable, correctement échappée :

```bash
git commit -m "type(scope): description en français"
```

Ne jamais exécuter cette commande à la place du demandeur.