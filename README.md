# Projet : Déploiement d’un site statique AWS multi-régions avec domaine personnalisé

## 🚀 Objectif du projet

Déployer un site statique sur Amazon Web Services, répliqué sur deux régions (us-east-1 et eu-west-1), avec distribution globale via CloudFront et sécurisé avec HTTPS (ACM). Le site est accessible via le domaine personnalisé **hkh24.xyz**.

---

## 🔧 Services AWS utilisés

* **Amazon S3** : stockage statique dans deux régions (us-east-1 et eu-west-1)
* **Amazon CloudFront** : répartition et cache de contenu
* **AWS Certificate Manager (ACM)** : certificat SSL pour HTTPS
* **Amazon Route 53** : gestion DNS et enregistrement A (Alias)
* **Terraform** : Infrastructure as Code pour l'automatisation du déploiement

---

## 📂 Organisation des fichiers

```
projet4/
│
├── main.tf              # Configuration complète de l'infrastructure
├── variables.tf         # Variables déclarées pour le projet
├── site/
│   ├── index.html       # Page principale du site
│   └── error.html       # Page personnalisée d'erreur 403/404
└── README.md            # Documentation du projet
```

---

## 📚 Étapes de mise en place

1. **Création des buckets S3**

   * `mon-site-multiregion-us` (us-east-1)
   * `mon-site-multiregion-eu` (eu-west-1)
   * Configuration des permissions et hosting statique

2. **Téléversement des fichiers HTML**

   * `index.html` et `error.html` dans chaque bucket

3. **Certificat SSL (ACM)**

   * Certificat demandé pour `hkh24.xyz` et `*.hkh24.xyz`
   * Validation DNS via Route 53

4. **CloudFront**

   * Distribution configurée avec Origin Access Identity (OAI)
   * Alias : `hkh24.xyz`
   * Certificat ACM région us-east-1 attaché

5. **Route 53**

   * Enregistrement A (Alias) pointant vers la distribution CloudFront

---

## ❌ Difficultés rencontrées

### 1. **Erreur SSL / Certificat invalide**

* **Problème** : Terraform retournait une erreur 400 `InvalidViewerCertificate`
* **Solution** : S'assurer que le certificat ACM était bien dans la région `us-east-1` et validé pour les bons domaines (incluant le wildcard)

### 2. **CloudFront non visible dans Route 53**

* **Problème** : Aucun endpoint CloudFront ne s’affichait lors de la création d’un enregistrement
* **Solution** : Bien activer l'option "Alias" et choisir "A – Routes traffic to AWS resource", puis CloudFront

### 3. **403 Forbidden sur S3/CloudFront**

* **Problème** : Accès refusé depuis CloudFront vers le contenu S3
* **Solution** : Ajouter une policy de bucket autorisant l'OAI à lire le contenu (`s3:GetObject`)

### 4. **DNS\_PROBE\_POSSIBLE / Domaine inaccessible**

* **Problème** : `hkh24.xyz` ne résolvait pas
* **Solution** : S'assurer que Route 53 gère bien la zone DNS du domaine, et que l’enregistrement A est correctement créé

---

## 🔍 Vérifications finales

* [x] [https://d1qffmd3yo1sxj.cloudfront.net](https://d1qffmd3yo1sxj.cloudfront.net) fonctionne
* [x] [https://hkh24.xyz](https://hkh24.xyz) fonctionne avec HTTPS
* [x] Aucun accès direct S3 autorisé (403 attendu)

---

## ✍️ Auteur

**NGAMUNA EYAY**
Projet réalisé dans le cadre d’une démonstration AWS Cloud & Terraform
Août 2025
