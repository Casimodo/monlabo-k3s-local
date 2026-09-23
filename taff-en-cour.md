# Travail en cours - AI Generation

Dernière mise à jour : 23 septembre 2026.

## Terminé

- Module natif macOS `ai-generation/`, hors K3s et Colima.
- Configuration locale limitée à `127.0.0.1` ou `localhost`.
- API FastAPI asynchrone avec les routes health, modèles, jobs, images et vidéos.
- File locale et gestionnaire limitant les modèles chargés et les générations simultanées.
- Provider image MFLUX 0.20.0 avec `Tongyi-MAI/Z-Image-Turbo` quantifié en 8 bits.
- Provider vidéo explicitement désactivé avec réponse HTTP 501.
- Stockage PNG et métadonnées JSON dans `ai-generation/outputs/`.
- Validation des prompts, dimensions, étapes, seeds, modèles et identifiants de fichiers.
- Interface Web responsive, onglets image/vidéo, polling des jobs, téléchargement et galerie.
- Scripts `deploy.sh`, `connect.sh` et `delete.sh`, avec PID et journal local.
- Documentation française et anglaise, plus index racine mis à jour.
- Tests sans modèle lourd : 8 tests réussis.
- Installation réelle vérifiée : MFLUX 0.20.0 et MLX 0.32.2.
- Serveur vérifié sur `127.0.0.1:8180` uniquement ; Web et health retournaient HTTP 200.
- Interface vérifiée dans le navigateur sur desktop et mobile, sans débordement horizontal.

## État actuel

- Le serveur a été arrêté ; le port 8180 n'écoute plus.
- `.venv`, le cache Hugging Face et les sorties sont conservés.
- Deux jobs GPU ont été créés pendant le test :
  - `8252512066e248c7815c4e287513242e`
  - `336c0ac2898944e5bf118b4bbe97a777`
- Le processus avait chargé environ 5,3 Gio de mémoire, mais aucun PNG ni JSON n'a été produit avant l'arrêt.
- Le journal ne contient pas encore de statut final exploitable pour ces jobs.
- Le test complet Browser -> API -> MFLUX -> MLX -> PNG reste donc à valider.

## Reprise recommandée

1. Démarrer le service :

   ```bash
   cd ai-generation
   ./deploy.sh
   ```

2. Ouvrir `http://127.0.0.1:8180` et lancer une image 512 x 512, 9 étapes, seed 42.

3. Pendant la génération, suivre uniquement le journal :

   ```bash
   tail -f .runtime/server.log
   ```

4. Attendre un état `completed` ou `failed` sans interrompre le serveur. Vérifier ensuite :

   ```bash
   ls -lh outputs/images
   file outputs/images/*.png
   ```

5. En cas d'échec, relever le message retourné par `/api/jobs/{id}` et les dernières lignes du journal avant toute modification.

6. Relancer les validations après correction :

   ```bash
   .venv/bin/python -m pytest -q
   bash -n deploy.sh connect.sh delete.sh scripts/*.sh
   ```

## Phase vidéo

Ne pas activer la vidéo sans test séparé. Wan 2.1 MLX est disponible, mais le modèle image-vers-vidéo documenté demande environ 39 Gio. Sur ce Mac M5 Pro 24 Gio, conserver `DisabledVideoProvider` tant qu'une solution réellement fiable et mesurée n'est pas identifiée.