# 🔧 Jenkins + GitHub — Guia de Integração

Projeto base para integrar o Jenkins com repositórios GitHub via webhook e GitHub Actions.

---

## 📁 Estrutura do Projeto

```
.
├── Jenkinsfile                        # Pipeline declarativa principal
├── Dockerfile                         # Exemplo de build Docker
├── scripts/
│   └── deploy.sh                      # Script de deploy por ambiente
├── .github/
│   └── workflows/
│       └── trigger-jenkins.yml        # GitHub Actions → aciona Jenkins
└── docs/
    └── SETUP.md                       # Guia detalhado de configuração
```

---

## ⚡ Início Rápido

### 1. Configure os Secrets no GitHub

Acesse `Settings → Secrets and variables → Actions` no seu repositório e adicione:

| Secret              | Valor                                      |
|---------------------|--------------------------------------------|
| `JENKINS_URL`       | `https://jenkins.suaempresa.com`           |
| `JENKINS_USER`      | Usuário do Jenkins                         |
| `JENKINS_TOKEN`     | API Token gerado no Jenkins                |
| `JENKINS_JOB_NAME`  | Nome do job (ex: `meu-app/main`)           |

### 2. Configure o Webhook no GitHub

1. `Settings → Webhooks → Add webhook`
2. **Payload URL:** `https://jenkins.suaempresa.com/github-webhook/`
3. **Content type:** `application/json`
4. **Events:** ✅ Push, ✅ Pull Requests

### 3. Configure o Job no Jenkins

1. Novo Job → **Multibranch Pipeline**
2. Branch Sources → **GitHub**
3. Credenciais → adicione um Personal Access Token do GitHub
4. Build Configuration → by Jenkinsfile
5. Scan Multibranch Pipeline Triggers → ✅ Periodically if not otherwise run

### 4. Plugins Necessários no Jenkins

Instale via `Manage Jenkins → Plugins`:

- ✅ **GitHub Integration Plugin**
- ✅ **GitHub Branch Source Plugin**
- ✅ **Pipeline**
- ✅ **GitHub Checks Plugin** (para status nos PRs)
- ✅ **Docker Pipeline** (se usar Docker)
- ✅ **Credentials Binding**

---

## 🔄 Fluxo da Pipeline

```
Push/PR no GitHub
      │
      ▼
GitHub Actions (trigger-jenkins.yml)
      │
      ▼
Jenkins recebe webhook
      │
      ├── Checkout
      ├── Install Dependencies
      ├── Lint & Code Quality
      ├── Test  ──────────────────► JUnit Reports
      ├── Build
      ├── Docker Build (se Dockerfile existir)
      │
      ├── [branch: develop] → Deploy Staging
      └── [branch: main]    → Aprovação manual → Deploy Production
```

---

## 🌿 Estratégia de Branches

| Branch         | Trigger        | Deploy         |
|----------------|----------------|----------------|
| `feature/**`   | Push           | Somente CI     |
| `develop`      | Push           | Staging        |
| `main`         | Push + Aprovação | Production   |
| `hotfix/**`    | Push           | Somente CI     |

---

## 🔐 Credenciais no Jenkins

Configure em `Manage Jenkins → Credentials`:

```
Kind:     Username with password
Username: seu-usuario-github
Password: ghp_SEU_PERSONAL_ACCESS_TOKEN
ID:       github-credentials
```

Para Docker Hub (se necessário):
```
Kind:     Username with password
ID:       dockerhub-credentials
```

---

## 📖 Documentação Adicional

Veja [docs/SETUP.md](docs/SETUP.md) para um guia passo a passo detalhado.
