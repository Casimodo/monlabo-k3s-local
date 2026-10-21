# v1.0.0

Premiere release de k8s-local, un environnement de services autonomes pour le developpement local. Ces configurations ne sont pas adaptees a la production.

## Services

- MariaDB avec stockage persistant, Vault en mode developpement, serveur Node.js avec Socket.IO et interface Rancher sur K3s local.
- Profils FiveM, FiveM Enhanced et RedM avec Docker local et ressources de jeu montees depuis la machine hote.
- AI Generation Lab pour la generation locale d'images sur Apple Silicon, avec API FastAPI et interface web.
- Commandes de deploiement, connexion, suppression et nettoyage, accompagnees de guides en francais et en anglais pour macOS, Linux et Windows.

## Garde-fous locaux

- Verification du contexte Kubernetes `k3s-local`, du kubeconfig explicite et d'une API locale ; refus des contextes Docker distants pour les profils Cfx.
- Acces aux services limites a l'interface locale et identifiants Kubernetes generes a l'installation dans des Secrets.
- Parcours macOS avec Colima et indications de depannage du cluster.

## Commits et publication

- Gitleaks en pre-commit et dans les CI GitLab et GitHub, sans analyse Sonar.
- Validation de la syntaxe Bash et des fichiers de release dans la CI.
- Skills Copilot `/release` et `/commit` pour preparer la version, les notes et le commit sans commit ni push automatique.
- Workflow GitHub publiant le tag et la release apres validation d'un push sur la branche par defaut.