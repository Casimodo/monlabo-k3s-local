# v1.0.2

## Corrections

- Desactivation du montage automatique du jeton de compte de service du pod MariaDB, qui n'utilise pas l'API Kubernetes.
- Ajout d'une demande de stockage ephemere de `128Mi` et d'une limite de `1Gi` au conteneur MariaDB. Le volume persistant de donnees de `5Gi` reste inchange.
