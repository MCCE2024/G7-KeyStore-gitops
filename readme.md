# 🔐 G7 KeyStore – GitOps Infrastructure
---
> Martin Kral, Benjamin Moser, Markus Sallmutter, Philipp Wildzeiss

Willkommen im GitOps-Repository für den **G7 KeyStore** – einer tenant-fähigen Schlüsselverwaltungsplattform, die vollständig über GitOps gesteuert wird.  
Dieses Repository enthält die Infrastruktur-Komponenten zur Auslieferung und Verwaltung der KeyStore-App innerhalb eines Kubernetes-Clusters via ArgoCD.

> 👉 Die zugehörigen Anwendungscode für dieses Beispiel findest du unter:
> https://github.com/MCCE2024/G7-KeyStore-app

## 🚀 Projektüberblick

**Ziel** dieses Projekts ist es, einem skalierbare und mandantenfähige Key-Store bereitzustellen, der sich per GitOps deklarativ verwalten lässt.  
Die Infrastruktur basiert auf Kubernetes und nutzt moderne GitOps-Prinzipien zur kontinuierlichen Bereitstellung und Konfiguration der Umgebung.
Die Infrastruktur wird hierbei mittels Infrastructure-as-Code automatisiert bereitgestellt und mittels Tools wie ArgoCD mandantenfähig konfiguriert.

## 🏠 Gesamtarchitektur
![Architekturdiagramm](https://github.com/user-attachments/assets/c34668fa-e66b-43d9-8ef1-e78d67c9bfcb)

## Projektstruktur

## 📁 Struktur dieses Repositories

```bash
.
├── argocd/                # ArgoCD-spezifische Konfiguration (Applicationset, Template für Application)
│   └── ...
├── helm-app/              # Helm-Chart für das Deployment einer Tenant-App über ArgoCD
│   └── ...
├── tenants/               # Spezifische Konfigurationen für die einzelnen Mandanten
│   └── ...
├── terraform/             # Terraform-Ordner für die automatisierte Bereitstellung der Infrastruktur
│   └── ...           
└── ...
```

## ⚙️ Eingesetzte Technologien

| Komponente         | Beschreibung                                           |
|--------------------|--------------------------------------------------------|
| **Kubernetes**     | Orchestrierung der gesamten Anwendung und Services     |
| **ArgoCD**         | GitOps Delivery Tool für automatisierte Deployments    |
| **Nginx Ingress**  | Routing & SSL Termination                              |
| **OAuth2 Proxy**   | Authentifizierung via OpenID Connect / OAuth2         |
| **Exoscale**       | Cloud Infrastruktur (Compute & Network)                |
| **OpenTofu**       | Open Source Alternative zu Terraform                  |

## 🚀 Workflow
![GitOps-Action](https://github.com/user-attachments/assets/5c2ee588-b79f-412b-b3a4-b151ede1f6bd)

## 🛠️ Erstellung eines neuen Tenants
1. Im Ordner "tenants/" muss ein neuer Ordner mit einem neuen .yaml-File (values.yaml) erstellt werden. Dieses besteht aus Tenant-spezifischen Einstellungen.
```yaml
tenantName: tenant-b
resources:
  requests:
    memory: "128Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```
2. In der Datei "terraform/terraform.tfvars" muss im Property "tenants" ein neuer Tenant hinterlegt werden. Dieser sollte die folgende Form haben.
```
 tenant-b = {
    namespace_name = "tenant-b"
    db_name        = "tenant-b-db"
    secret_name    = "tenant-b-db-secret"
    exoscale_zone  = "at-vie-2"
  }
```
3. Nachdem die beiden Änderungen auf dem Main-Branch gepusht wurden, wird der in [Workflow](##🚀Workflow) dargestellte Workflow ausgeführt. Es wird automatisiert die Datenbank in Exoscale provisioniert und die Secrets in K8S in einen eigenen Namespace hinterlegt. Daraufhin deployt ArgoCD den Helm-Chart in den Namespace, wodurch die Application läuft.

---

## ✅ Installation

Wenn man das Repository klont, und bei sich selbst in Github hostet, muss lediglich das Exoscale-Keypair bestehend aus API-Key und API-Secret in die Repository Settings hinterlegt werden. Dafür unter Exoscale -> IAM -> Keys -> einen neuen Key mit Admin-Rechten hinzufügen und die angezeigten Secrets daraufhin mit den folgenden Identifiern in die Github Action Secrets hinterlegen. Die einzelnen Secrets für die OAuth2-Authentication müssen ebenfalls hinterlegt werden. Hier der offizielle Guide: 
> https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app

| Identifier         | Beschreibung                                           |
|--------------------|--------------------------------------------------------|
| **EXOSCALE_KEY**     | Exoscale API-Key     |
| **EXOSCALE_SECRET**         | Exoscale API-Secret    |
| **OAUTH2_CLIENT_ID**         | OAuth-2-Client-Id des Github-Providers    |
| **OAUTH2_CLIENT_SECRET**         | Oauth-2-Secret des Github-Providers.   |
| **OAUTH2_COOKIE_SECRET**         | Oauth-2-Cookie-Secret (Base-64 Encoded Secret)   |

## 📌 Wo hatten wir unsere Probleme / Was wurde nicht fertig?

## Screenshots
![Deployte Datenbank in Exoscale](https://github.com/user-attachments/assets/0bb19e9e-e04d-4c02-921b-4273090b056e)
![Tenant-Frontend](https://github.com/user-attachments/assets/0eda2e44-d5fb-4793-b87e-27c2fcf9522c)
![ArgoCD - Überblick](https://github.com/user-attachments/assets/b798716a-777a-4d98-b715-ccbb2e9a56c2)
![ArgoCD - Deployter Tenant](https://github.com/user-attachments/assets/456353cf-72e3-4988-a166-051bbe804582)







