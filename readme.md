# 🔐 G7 KeyStore – GitOps Infrastructure

---
> Martin Kral, Benjamin Moser, Markus Sallmutter, Philipp Wildzeiss

Willkommen im GitOps-Repository für den **G7 KeyStore** – einer tenant-fähigen Schlüsselverwaltungsplattform, die vollständig über GitOps gesteuert wird.  
Dieses Repository enthält die Infrastruktur-Komponenten zur Auslieferung und Verwaltung der KeyStore-App innerhalb eines Kubernetes-Clusters via ArgoCD.

> 👉 Die zugehörigen Anwendungscode für dieses Beispiel findest du unter:
> <https://github.com/MCCE2024/G7-KeyStore-app>

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

Wenn man das Repository klont, und bei sich selbst in Github hostet, muss das Exoscale-Keypair bestehend aus API-Key und API-Secret in die Repository Settings hinterlegt werden. Dafür unter Exoscale -> IAM -> Keys -> einen neuen Key mit Admin-Rechten hinzufügen und die angezeigten Secrets daraufhin mit den folgenden Identifiern in die Github Action Secrets hinterlegen. Für den Argocd Image Updater wird in diesem Projekt die Write-Back-Methode "git" verwendet. Daher wird neben dem Exoscale-Keypair ebenfalls noch die Github Credentials mit Username und Personal access tokens vom Typ "Fine-grained tokens" benötigt. Beim Erstellen des Tokens sollte "Only select repository" ausgewählt werden und bei den "Repository permissions" werden die Permissions "Contents" und "Pull requests" benötigt, damit ArgoCD die Parameter für die gerade verwendeten Image Tags ins Git Repo pushen kann. Die Credentials sind wie das Exoscale-Keypair in Github Action Secrets zu speichern. Die einzelnen Secrets für die OAuth2-Authentication müssen ebenfalls hinterlegt werden. Hier der offizielle Guide:
> <https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/creating-an-oauth-app>

| Identifier         | Beschreibung                                           |
|--------------------|--------------------------------------------------------|
| **EXOSCALE_KEY**     | Exoscale API-Key     |
| **EXOSCALE_SECRET**         | Exoscale API-Secret    |
| **OAUTH2_CLIENT_ID**         | OAuth-2-Client-Id des Github-Providers    |
| **OAUTH2_CLIENT_SECRET**         | Oauth-2-Secret des Github-Providers.   |
| **OAUTH2_COOKIE_SECRET**         | Oauth-2-Cookie-Secret (Base-64 Encoded Secret)   |
| **TF_VAR_git_username**         | GitHub Username   |
| **TF_VAR_git_token**         | GitHub Personal Access Token   |

Neben dem Anlegen der GitHub Action Secrets ist es noch nötig in Exoscale manuell einen Object Storage mit dem Namen "my-terraform-state" in der Zone "vie-1" anzulegen. Hier wird der Status von terraform gespeichert. Terraform legt in diesem Storage automatisch die Datei terraform.tfstate im Verzeichnis "infra" an. Die genaue Deklaration findet man im backend.tf.

## 📌 Wo hatten wir unsere Probleme / Was wurde nicht fertig?

Im Laufe des Projekts sind wir auf mehrere Hürden gestoßen:

---

### 🧩 Kubeconfig im GitHub Actions Workflow

Eine der größten Herausforderungen war die Verwendung der **kubeconfig** im GitHub Actions Workflow.  
Da zuerst der Kubernetes Cluster erstellt werden muss, um anschließend den Namespace für den jeweiligen Tenant und die Datenbank-Credentials in Kubernetes Secrets speichern zu können, war es notwendig, sich die **kubeconfig** über die **exo CLI** zu holen.

Allerdings trat hier immer ein Fehler während der CI-Pipeline auf.  
Wir haben verschiedene Installationsvarianten der **exo CLI** ausprobiert – ohne Erfolg.

**Lösung:**  
Wir haben herausgefunden, dass für das Exportieren der kubeconfig über die **exo CLI** die **Exoscale Keypairs** (API-Key und API-Secret) im Environment des Workflows vorhanden sein müssen.  
Daher haben wir die beiden Umgebungsvariablen `EXOSCALE_API_KEY` und `EXOSCALE_API_SECRET` angelegt, die über **GitHub Actions Secrets** bereitgestellt werden.

---

### ⚙️ kubectl apply – Ressourcen-Definition in Terraform

Nachdem das kubeconfig-Problem gelöst war, konnten in Phase zwei der `kubectl apply`-Aufrufe die Datenbanken für die Tenants, der Ingress und auch **ArgoCD** nicht fehlerfrei deployed werden.

**Problem:**  
Zuerst hatten wir alle Ressourcen in der Datei `main.tf` definiert. Beim zweiten Aufruf von `kubectl apply` wurde aber der Kubernetes Provider nicht erkannt.

**Lösung:**  
Nach Recherche haben wir herausgefunden, dass Ressourcen in eigene **Terraform-Module** ausgelagert werden müssen, wobei jedem Modul explizit die benötigten Provider mitgegeben werden.  
Deshalb haben wir für **Tenants**, **Ingress** und **ArgoCD** jeweils eigene Module erstellt und diese im `main.tf` eingebunden.

---

### 🗃️ Terraform State Handling

Auch das Speichern des Terraform State im GitHub Actions Workflow war eine Herausforderung:

**Problem:**  
Der erste Durchlauf des Workflows funktionierte, aber beim Hinzufügen neuer Tenants war der State beim zweiten Durchlauf der CI-Pipeline nicht mehr verfügbar. Terraform versuchte, denselben Kubernetes Cluster erneut zu erstellen.

**Lösung:**  
Die Herausforderung lag darin, dass man bei der Erstellung des Object Storage auf Exoscale AWS Daten angeben musste, wie die Region von AWS oder im Workflow die env-Variablen `AWS_ACCESS_KEY_ID` und `AWS_SECRET_ACCESS_KEY`, welche die Exoscale API Key und API Secrets sind. Die genaue Definition für den Object Storage findet man im `backend.tf`.

---

### 🔄 ArgoCD Image Updater

Ein weiteres großes Problem betraf den **ArgoCD Image Updater**.

**Vorgehensweise & Problem:**  
Zuerst versuchten wir es mit der Write-Back-Methode `argocd`.  
Nach Änderung der Key-Store-Applikation im G7-KeyStore-app Repository und einem Push in den `main` Branch wurden die neuen Images zwar auf Docker Hub veröffentlicht, aber nicht durch den ArgoCD Image Updater im Kubernetes Cluster deployed. Die Ursache war unklar – Änderungen am Updater hatten keine sichtbare Wirkung.

**Lösungsschritte:**

1. Mit folgendem Befehl konnten wir die Logs des ArgoCD Image Updater einsehen:
   ```bash
   kubectl --kubeconfig=./kubeconfig logs -n argocd deploy/argocd-image-updater -f
2. Dadurch stellten wir fest, dass die Images gar nicht erkannt wurden.
3. Die Ursache war ein fehlerhafter Pfad bei der Angabe der `valueFiles`.
4. Nach Korrektur wurde das Image zwar erkannt, ging jedoch in den "pending"-Status und wurde dadurch nicht aktualisiert.

Da wir dieses Problem nicht lösen konnten, sind wir auf die Write-Back-Methode `git` umgestiegen.
Vorteil: ArgoCD pusht den aktuellen Stand der verwendeten Images direkt ins Repository, was auch einen Versionsverlauf ermöglicht. Die Änderungen werden für jeden Tenant im helm-app Verzeichnis in der Datei `.argocd-source-<Tenant-Bezeichnung>-app.yaml` gespeichert. Mit dieser Methode hat es schließlich funktioniert.

### 🌐 Routing im Frontend

Unsere Applikation läuft erfolgreich auf dem Kubernetes Cluster und ist erreichbar.

**Problem:**  
Beim Wechseln auf Unterseiten im Frontend funktionierte das Routing nicht korrekt.

**Lösungsschritte:**

Hierfür musste explizit beim Routing auf die weiteren Seiten auf das Präfix in der Route geachtet werden und dieses berücksichtigt werden. Zusätzlich musste das Präfix über eine Environment-Variable gesetzt werden, damit das dynamische konfigurieren des Routings korrekt funktioniert.
```csharp
// Setzen des Basis-Pfads auf die Environment-Variable (Views)
app.UsePathBase($"/{AppName}");
```

```razor
# Setzen des Basis-Pfads auf die Environment-Variable (Resourcen)
<base href="/@Frontend.Program.AppName/" />
```

## Screenshots

![Deployte Datenbank in Exoscale](https://github.com/user-attachments/assets/0bb19e9e-e04d-4c02-921b-4273090b056e)
![OAuth2-Authentication](https://github.com/user-attachments/assets/77244547-0f06-44d1-9c15-c499b6a3f883)
![Tenant-Frontend](https://github.com/user-attachments/assets/0eda2e44-d5fb-4793-b87e-27c2fcf9522c)
![ArgoCD - Überblick](https://github.com/user-attachments/assets/b798716a-777a-4d98-b715-ccbb2e9a56c2)
![ArgoCD - Deployter Tenant](https://github.com/user-attachments/assets/456353cf-72e3-4988-a166-051bbe804582)
