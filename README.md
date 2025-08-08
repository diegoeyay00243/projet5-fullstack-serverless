# 🚀 Projet Cloud AWS — Hébergement Statique Multi-Région + Backend Serverless

> *Projet démonstratif complet en infrastructure AWS avec Terraform modulaire.*  
> Réalisé en août 2025 

---

## 🎯 Objectif

Ce projet déploie une **infrastructure complète cloud sur AWS** avec **Terraform**, combinant :

- 🌍 Un site statique **multi-région** via Amazon S3 (us-east-1 & eu-west-1)
- 🌐 Un CDN **CloudFront** avec HTTPS (via certificat SSL ACM)
- 🧾 Un domaine personnalisé : `https://hkh24.xyz`
- 📨 Un **formulaire de contact** backend via Lambda + API Gateway
- 🗃️ Une base NoSQL **DynamoDB** pour stocker les messages
- 🔒 Une **VPC personnalisée** avec subnets publics/privés & NAT Gateway

---

## 🧰 Stack technique

| Service AWS         | Rôle                                           |
|---------------------|------------------------------------------------|
| S3                  | Hébergement du site statique (x2 régions)      |
| CloudFront          | CDN global avec HTTPS                          |
| ACM + Route 53      | Certificat SSL + domaine custom                |
| Lambda (Node.js)    | Fonction backend pour le formulaire de contact |
| API Gateway         | Point d'entrée REST `/contact`                 |
| DynamoDB            | Stockage des messages envoyés                  |
| VPC/Subnets/NAT     | Isolation réseau et sortie sécurisée           |
| Terraform Modules   | IaC modulaire pour chaque composant            |

---

## 🗂️ Structure du projet

```bash
projet/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── versions.tf
├── modules/
│   ├── vpc/
│   ├── lambda/
│   ├── api_gateway/
│   └── dynamodb/
├── site/
│   ├── index.html
│   └── error.html
├── lambda/
│   ├── index.js
│   └── lambda.zip
└── docs/
    └── architecture.png
```

---

## 🧠 Lambda (Node.js)

```js
// lambda/index.js
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const body = JSON.parse(event.body);
  const message = body.message;

  if (!message) return { statusCode: 400, body: 'Message is required' };

  await dynamodb.put({
    TableName: process.env.TABLE_NAME,
    Item: {
      id: uuidv4(),
      message,
      timestamp: new Date().toISOString()
    }
  }).promise();

  return {
    statusCode: 200,
    body: JSON.stringify({ success: true })
  };
};
```

---

## 🔧 Déploiement

### 📋 Prérequis
- ✅ AWS CLI configuré (`aws configure`)
- ✅ Un domaine Route 53 actif (ex : `hkh24.xyz`)
- ✅ Terraform ≥ 1.4 installé
- ✅ SMTP configuré (`email_sender`, `email_password`, `email_receiver`)

### 🚀 Commandes de déploiement

```bash
terraform init      # Initialiser Terraform
terraform plan      # Vérifier le plan
terraform apply     # Lancer l'infra
```

---

## 🌐 URLs générées

| Composant              | URL |
|------------------------|-----|
| Site S3 (US)           | http://mon-site-multiregion-us.s3-website-us-east-1.amazonaws.com |
| Site S3 (EU)           | http://mon-site-multiregion-eu.s3-website-eu-west-1.amazonaws.com |
| CDN CloudFront         | https://hkh24.xyz |
| API REST (Lambda POST) | `https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/contact` |

---

## 🛠️ Troubleshooting (Erreurs & Résolutions)

| Problème rencontré | Solution appliquée |
|--------------------|---------------------|
| `lambda.zip not found` | Vérifier le chemin exact et le passer correctement à `lambda_zip_path` |
| `ResourceConflictException` (Lambda / IAM / S3) | Nettoyer les ressources existantes (`terraform destroy`) ou renommer |
| `CNAMEAlreadyExists (CloudFront)` | Un domaine est déjà associé. Utiliser un autre nom ou supprimer l'ancien |
| `Lambda ImportModuleError` | Vérifier que `lambda.zip` contient bien `index.js` à la racine, avec les bonnes dépendances (npm install si besoin) |

---

## 📚 Leçons apprises

- Mise en œuvre complète de Terraform modulaire
- Déploiement multi-région (S3)
- Configuration d’un CDN HTTPS (CloudFront + ACM)
- Création d’un backend serverless (Lambda, API Gateway)
- Gestion de réseau cloud avec VPC, subnets, NAT Gateway
- Débogage avancé sur AWS (CloudWatch, permissions, logs...)

---

## 🌱 Améliorations possibles

- Ajouter une interface d’admin pour voir les messages envoyés (via Cognito ?)
- Exporter les messages DynamoDB dans S3 (Lambda trigger ?)
- Ajouter tests automatisés (Terraform + fonction Lambda)
- Passer les secrets (SMTP) par AWS Secrets Manager

---

## 🧠 Architecture du projet

📷 *Diagramme d’architecture disponible dans `/docs/architecture.png`*  
*(inclure l’image dans le README GitHub si besoin avec `![diagramme](./docs/architecture.png)`).*

---

## 👨‍💻 Auteur

> **Ngamuna Eyay**  
> Ingénieur Cloud & DevOps  
> 📆 Août 2025  
> 📫 ngamunaeyay2@gmail.com  

---

**Merci pour votre lecture 🙌**  
*Projet disponible sur GitHub — N’hésitez pas à étoiler ou commenter !*
