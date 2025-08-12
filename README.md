# 🚀 Projet Cloud AWS — Hébergement Statique Multi-Région + Backend Serverless

> *Infra complète AWS pilotée par Terraform (modulaire) et déployée en CI/CD via GitHub Actions + OIDC (zéro clé longue durée).*  
> Réalisé en **août 2025**

[![CI/CD](https://github.com/diegoeyay00243/projet5-fullstack-serverless/actions/workflows/deploy.yml/badge.svg)](../../actions)

---

## 🎯 Objectif

Déployer une **plateforme serverless** sur AWS combinant :

- 🌍 Site statique **multi-région** sur Amazon **S3** (us-east-1 & eu-west-1)  
- 🌐 **CloudFront** en HTTPS (ACM) et domaine personnalisé `https://hkh24.xyz`  
- 📨 **Formulaire de contact** via **Lambda (Node.js)** + **API Gateway**  
- 🗃️ **DynamoDB** pour persister les messages  
- 🔒 **VPC** dédiée (subnets publics/privés, NAT)  
- 🤖 **CI/CD GitHub Actions** avec **OIDC** (assume role IAM, pas de clés stockées)

---

## 🧰 Stack technique

| Service / Outil       | Rôle                                                                 |
|-----------------------|----------------------------------------------------------------------|
| **S3**                | Hébergement du site (2 régions)                                      |
| **CloudFront**        | CDN global + HTTPS (certificat **ACM**)                              |
| **Route 53**          | DNS du domaine `hkh24.xyz`                                           |
| **Lambda (Node.js)**  | Handler du formulaire /contact                                       |
| **API Gateway**       | Endpoint REST vers la Lambda                                         |
| **DynamoDB**          | Table des messages                                                   |
| **VPC/Subnets/NAT**   | Isolation réseau                                                     |
| **Terraform**         | IaC modulaire (modules vpc, lambda, api_gateway, dynamodb)           |
| **GitHub Actions**    | CI/CD Terraform (fmt/init/validate/plan/apply) via **OIDC**          |

---

## 🗂️ Structure du projet

```bash
projet/
├── main.tf
├── variables.tf               # contient lambda_zip_path + variables email
├── outputs.tf
├── versions.tf
├── terraform.tfvars           # (optionnel, pour exécutions locales)
├── modules/
│   ├── vpc/
│   ├── lambda/
│   ├── api_gateway/
│   └── dynamodb/
├── site/
│   ├── index.html
│   ├── error.html
│   └── lambda.zip             # artefact Lambda consommé par Terraform
├── lambda/
│   └── index.js               # code source de la Lambda
└── .github/workflows/
    └── deploy.yml             # pipeline CI/CD Terraform


🧠 Lambda (Node.js) — exemple minimal

// lambda/index.js
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const body = JSON.parse(event.body || "{}");
  const message = body.message;

  if (!message) return { statusCode: 400, body: 'Message is required' };

  await dynamodb.put({
    TableName: process.env.TABLE_NAME,
    Item: { id: uuidv4(), message, timestamp: new Date().toISOString() }
  }).promise();

  return { statusCode: 200, body: JSON.stringify({ success: true }) };
};


🔐 CI/CD GitHub Actions (OIDC)
Côté AWS (IAM)
Identity Provider OIDC : token.actions.githubusercontent.com
Audience : sts.amazonaws.com

Rôle IAM assumable via OIDC (Trust policy – extrait) :

Principal.Federated = arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com

Condition.StringEquals["token.actions.githubusercontent.com:aud"] = "sts.amazonaws.com"

Condition.StringLike["token.actions.githubusercontent.com:sub"] = "repo:diegoeyay00243/projet5-fullstack-serverless:*"

Attacher une policy adaptée (AdminAccess en phase dev, à restreindre ensuite).

Côté GitHub (Secrets & Variables)
Secrets (Settings → Secrets and variables → Actions → New repository secret)

AWS_OIDC_ROLE_ARN → arn:aws:iam::<account-id>:role/GHAOIDC-Terraform

EMAIL_SENDER → adresse expéditrice (ex. Gmail)

EMAIL_PASSWORD → mot de passe d’application Gmail (cf. guide plus bas)

EMAIL_RECEIVER → adresse destinataire pour tests

Variables (onglet Variables)

LAMBDA_ZIP_PATH → chemin de l’archive Lambda (ex. site/lambda.zip)

Le workflow injecte automatiquement ces valeurs dans Terraform via TF_VAR_* :

yaml
Copier
Modifier
env:
  TF_VAR_lambda_zip_path: ${{ vars.LAMBDA_ZIP_PATH || secrets.LAMBDA_ZIP_PATH }}
  TF_VAR_email_sender:   ${{ secrets.EMAIL_SENDER }}
  TF_VAR_email_password: ${{ secrets.EMAIL_PASSWORD }}
  TF_VAR_email_receiver: ${{ secrets.EMAIL_RECEIVER }}
🔧 Déploiement
📋 Prérequis
Terraform ≥ 1.4

(Optionnel) AWS CLI configurée

Domaine Route 53 si vous utilisez CloudFront + ACM

Secrets : AWS_OIDC_ROLE_ARN, EMAIL_SENDER, EMAIL_PASSWORD, EMAIL_RECEIVER

Variable : LAMBDA_ZIP_PATH (par ex. site/lambda.zip)

Archive Lambda : créez-la si besoin :

bash
Copier
Modifier
zip -r site/lambda.zip lambda/*
🚀 Via GitHub Actions (recommandé)
push sur main → apply automatique

pull_request → plan uniquement

Déclenchement manuel :

bash
Copier
Modifier
gh workflow run deploy.yml -R diegoeyay00243/projet5-fullstack-serverless --ref main
🧪 En local
bash
Copier
Modifier
terraform fmt -recursive
terraform init -input=false
terraform validate
terraform plan
terraform apply -auto-approve
🌐 URLs générées
Composant	URL (exemple)
Site S3 (US)	http://mon-site-multiregion-us.s3-website-us-east-1.amazonaws.com
Site S3 (EU)	http://mon-site-multiregion-eu.s3-website-eu-west-1.amazonaws.com
CDN CloudFront	https://hkh24.xyz
API REST (POST)	https://<api_id>.execute-api.us-east-1.amazonaws.com/prod/contact

🧱 Ce qui rend ce projet “pro”
CI/CD GitHub Actions sans clés : OIDC assume un rôle IAM dédié (trust policy restreinte par aud/sub).

Gates de qualité dans le pipeline : fmt (soft), init, validate, plan/apply.

Sécurité : secrets chiffrés GitHub, zéro secret commité, OIDC only.

Traçabilité : étape aws sts get-caller-identity pour logguer l’ARN assumé.

État Terraform backend S3 (persistance d’équipe/CI). (ajoutez un lock DynamoDB si besoin)

Modularité : modules vpc, lambda, api_gateway, dynamodb.

Packaging reproductible : site/lambda.zip (ou job de build dédié).

Diagnostics : workflow OIDC diag (impression des claims & identité STS).

🛠️ Troubleshooting
Problème	Cause probable	Solution
sts:AssumeRoleWithWebIdentity refusé	Trust policy incomplète (aud/sub) ou mauvais rôle/IdP	Vérifier IdP token.actions.githubusercontent.com, aud = sts.amazonaws.com, sub = repo:<owner>/<repo>:*, secret AWS_OIDC_ROLE_ARN
terraform fmt → code 3	Fichiers non formatés	terraform fmt -recursive puis commit
No value for required variable	TF_VAR_* manquants	Créer secrets/variables et vérifier env: du workflow
lambda.zip not found	Mauvais chemin/artefact absent	Vérifier LAMBDA_ZIP_PATH et générer site/lambda.zip
ImportModuleError Lambda	Archive incomplète	Vérifier contenu du zip (index.js, dépendances)
CNAMEAlreadyExists CloudFront	Domaine déjà pris	Libérer l’alias ou utiliser un autre nom

📜 Mot de passe d’application Gmail (EMAIL_PASSWORD)
Compte Google → Sécurité → activer Validation en 2 étapes.

Toujours dans Sécurité → Mots de passe d’application.

Créer (ex. App: Mail, Appareil: GitHub Actions) → copier le code 16 caractères.

Le mettre dans le secret EMAIL_PASSWORD.

⚠️ C’est différent de votre mot de passe normal ; il ne s’affiche qu’une seule fois.

✅ Bonnes pratiques / Prochaines étapes
Durcir : protections de branche, reviewers obligatoires, fmt bloquant sur PR.

Least privilege : remplacer AdminAccess par une policy IAM sur mesure (S3/CF/Lambda/APIGW/DynamoDB).

Lock Terraform : table DynamoDB pour verrouiller l’état.

Job de build Lambda : étape CI qui zippe, publie l’artefact et l’injecte au apply.

Tests : tflint/terraform-compliance, tests Lambda (Jest), scans sécurité.

🧠 Architecture
📷 Diagramme : ./docs/architecture.png
(Intégrable dans ce README : ![diagramme](./docs/architecture.png)).

👨‍💻 Auteur
Ngamuna Eyay — Ingénieur Cloud & DevOps
📆 Août 2025 • 📫 ngamunaeyay2@gmail.com

Merci pour votre lecture 🙌 — N’hésitez pas à ⭐ le dépôt et ouvrir des issues !