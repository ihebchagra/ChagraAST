# ChagraAST

ChagraAST est une application conçue pour aider les techniciens de laboratoire et les biologistes dans la lecture et l'interprétation des antibiogrammes par diffusion en milieu gélosé. Elle permet de gérer les prélèvements, d'analyser les images des boîtes de Petri, de mesurer les diamètres d'inhibition et de générer des rapports interprétatifs.

## Fonctionnalités

*   **Gestion des prélèvements** : Enregistrez et suivez les informations des patients et des prélèvements (numéro, nom, service, etc.).
*   **Gestion des isolats** : Associez un ou plusieurs isolats bactériens à chaque prélèvement.
*   **Analyse d'images** : Uploadez une photo de votre boîte d'antibiogramme. L'application détecte automatiquement les disques et mesure les diamètres des zones d'inhibition.
*   **Correction manuelle** : Ajustez, renommez ou supprimez les disques détectés directement sur l'image pour une précision maximale.
*   **Ajout de résultats complémentaires** : Saisissez manuellement des résultats non issus de la diffusion (ex: CMI).
*   **Interprétation automatisée** : Obtenez une interprétation (S/I/R) basée sur les seuils critiques (cutoffs) spécifiques à l'espèce bactérienne identifiée.
*   **Génération de rapports** : Imprimez un compte-rendu clair et concis pour le dossier du patient.

## Dépendances

Ce projet dépend d'une image Docker disponible sur :  
[github.com/ihebchagra/AST-image-processing](https://github.com/ihebchagra/AST-image-processing)

## Lancement de l'application

Avant de démarrer le serveur, vous devez construire l'application :

```bash
make rebuild
```

Ensuite, lancez le serveur avec :

```bash
make dev
```

L'application sera alors accessible à l'adresse `http://localhost:6420`.

## Licence

Ce projet est distribué sous la licence **GNU General Public License v3.0**. Voir le fichier `LICENSE` pour plus de détails.
