# DevOps Head – Practical Assessment

This repository contains my submission for the **DevOps Head – Practical Assessment**, covering production server setup, application deployment, CI/CD automation, Infrastructure as Code, production architecture design, and incident response documentation.

📁 **Repository:** [malayjoshi/malayjoshi.github.io](https://github.com/malayjoshi/malayjoshi.github.io)
🎥 **Walkthrough Video (Google Drive):** [Link](https://drive.google.com/file/d/18zfLLFckFKoGxUvsY9JVyr6nrX9Hkz2x/view?usp=sharing)

> Note: this repo also hosts my personal portfolio site (`index.html`, `app.js`, `style.css`, served via GitHub Pages). The assessment deliverables live in `task-1-git/`, `task-2/`, `flask-app/`, and `.github/workflows/` below.

---

## 📌 Overview

| Task | Description | Marks |
|------|-------------|-------|
| Task 1 | Production Server Setup & Application Deployment | 50 |
| Task 2 | DevOps Automation & Production Architecture | 50 |

---

## ✅ Task 1: Production Server Setup & Application Deployment

Configuration of a fresh Ubuntu VM for production use.

### Scope
- Non-root deployment user creation
- Root SSH login disabled; key-based authentication enabled
- UFW (firewall) and Fail2Ban configured
- Automatic security updates enabled
- Sample application deployed via Docker and Docker Compose
- Nginx reverse proxy configured with HTTPS (Let's Encrypt / self-signed)
- Monitoring for CPU, Memory, Disk, Containers, and Application availability
- Documentation covering deployment, security, monitoring, backup, and recovery

### Deliverables
- [ ] Git repository (this repo)
- [ ] Sample app Docker/Compose setup (`sample-app-docker/docker-compose.yml.txt`)
- [ ] Nginx configuration with SSL (`sample-app-docker/nginx_config_ssl.txt`)
- [ ] Observability stack — Docker/Compose + Prometheus (`observability-docker/docker-compose.yml.txt`, `observability-docker/prometheus.yml.txt`)
- [ ] `README.md` (this file)
- [ ] Full deployment, security, monitoring, backup & recovery write-up (`DevOps_Assignment_Report.pdf`)
- [ ] Monitoring & application screenshots (in report / linked via Google Drive)
- [ ] 5–10 minute walkthrough video (linked via Google Drive above)

### Repository Structure (Task 1)
```
task-1-git/
├── observability-docker/
│   ├── docker-compose.yml.txt
│   └── prometheus.yml.txt
├── sample-app-docker/
│   ├── docker-compose.yml.txt
│   └── nginx_config_ssl.txt
└── DevOps_Assignment_Report.pdf

flask-app/
└── (sample application deployed via sample-app-docker's Docker/Compose + Nginx setup)
```

---

## ✅ Task 2: DevOps Automation & Production Architecture

### Part A – CI/CD
Pipeline covering Build → Test → Docker Image Build → Registry Push → Deployment → Health Check → Rollback.
- Tooling: GitHub Actions
- Config: `github_actions_pipeline/pipeline.yml` (also mirrored as `cloud_architecture_configs/github-ci.yaml`)

### Part B – Infrastructure as Code
Terraform templates provisioning:
- VPC (`vpc.tf`)
- Compute (`compute.tf`)
- Database (`db.tf`, plus `cloud_architecture_configs/terraform-db.tf`)
- Security Groups (`security_groups.tf`)
- Storage (`storage.tf`)
- Load Balancer / ALB (`alb.tf`)
- Variables & Outputs (`variables.tf`, `outputs.tf`)

Location: `task-2/terraform/`

### Part C – Architecture
Production-ready SaaS architecture design including:
- Load Balancer & Reverse Proxy (`cloud_architecture_configs/nginx.conf`)
- Kubernetes ingress & GitOps deployment (`cloud_architecture_configs/k8s-ingress.yaml`, `cloud_architecture_configs/argocd-app.yaml`)
- Monitoring/alerting rules (`cloud_architecture_configs/prometheus-rules.yaml`)
- Secrets Management (`cloud_architecture_configs/vault-policy.hcl`)
- Database, Storage, Load Balancer (via `terraform/`)
- Backup, Disaster Recovery, High Availability, Security — documented in the architecture write-up

Location: `task-2/cloud_architecture_configs/`

### Part D – Incident Response
Documented troubleshooting process for a production `502 Bad Gateway` error.

Doc: `task-2/incident_response_502.md`

### Repository Structure (Task 2)
```
task-2/
├── cloud_architecture_configs/
│   ├── argocd-app.yaml
│   ├── github-ci.yaml
│   ├── k8s-ingress.yaml
│   ├── nginx.conf
│   ├── prometheus-rules.yaml
│   ├── terraform-db.tf
│   └── vault-policy.hcl
├── github_actions_pipeline/
│   └── pipeline.yml
├── terraform/
│   ├── alb.tf
│   ├── compute.tf
│   ├── db.tf
│   ├── outputs.tf
│   ├── security_groups.tf
│   ├── storage.tf
│   ├── variables.tf
│   └── vpc.tf
└── incident_response_502.md
```

---

## 🛠️ Tech Stack
- **OS:** Ubuntu (LTS)
- **Containerization:** Docker, Docker Compose
- **Reverse Proxy / TLS:** Nginx (SSL-enabled, `nginx_config_ssl.txt`)
- **Server Hardening:** UFW, Fail2Ban, unattended-upgrades (documented in `DevOps_Assignment_Report.pdf`)
- **CI/CD:** GitHub Actions, ArgoCD (GitOps)
- **IaC:** Terraform
- **Orchestration:** Kubernetes (ingress-based routing)
- **Monitoring:** Prometheus (metrics + alerting rules)
- **Secrets Management:** HashiCorp Vault
- **Cloud:** AWS (VPC, ALB, EC2/compute, RDS-style DB, S3-style storage)

---

## 📋 Evaluation Parameters Mapping

| Parameter | Marks | Where to find it |
|---|---|---|
| Linux & Security | 20 | `task-1-git/DevOps_Assignment_Report.pdf` (user, SSH, UFW, Fail2Ban, auto-updates sections) |
| Docker & Deployment | 20 | `task-1-git/sample-app-docker/`, `flask-app/` |
| CI/CD | 15 | `task-2/github_actions_pipeline/pipeline.yml`, `task-2/cloud_architecture_configs/github-ci.yaml`, `task-2/cloud_architecture_configs/argocd-app.yaml` |
| Infrastructure as Code | 15 | `task-2/terraform/` |
| Monitoring | 10 | `task-1-git/observability-docker/`, `task-2/cloud_architecture_configs/prometheus-rules.yaml` |
| Troubleshooting | 10 | `task-2/incident_response_502.md` |
| Architecture & Documentation | 10 | `task-2/cloud_architecture_configs/`, `task-1-git/DevOps_Assignment_Report.pdf` |

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone https://github.com/malayjoshi/malayjoshi.github.io.git
cd malayjoshi.github.io

# Task 1 — Deploy the sample app
cd task-1-git/sample-app-docker
cp docker-compose.yml.txt docker-compose.yml
docker-compose up -d

# Task 1 — Bring up observability stack
cd ../observability-docker
cp docker-compose.yml.txt docker-compose.yml
docker-compose up -d

# Task 2 — Provision infrastructure
cd ../../task-2/terraform
terraform init
terraform plan
terraform apply
```

---

## 📝 Assumptions

Assumptions made during implementation (cloud provider, domain name, instance sizing, etc.) are documented in [`task-1-git/DevOps_Assignment_Report.pdf`](task-1-git/DevOps_Assignment_Report.pdf).

---

## 👤 Author

**Malay Joshi**
[GitHub](https://github.com/malayjoshi) · [LinkedIn](https://www.linkedin.com/) · #MalayBuilds
