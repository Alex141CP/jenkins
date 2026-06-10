# 📋 SETUP.md — Guia Detalhado

## 1. Pré-requisitos

- Jenkins 2.400+ instalado e acessível publicamente (ou via ngrok para testes locais)
- GitHub com permissão de admin no repositório
- Java 17+ no servidor Jenkins

---

## 2. Gerando o Personal Access Token (PAT) no GitHub

1. GitHub → `Settings → Developer settings → Personal access tokens → Tokens (classic)`
2. `Generate new token`
3. Permissões necessárias:
   - `repo` (acesso completo)
   - `admin:repo_hook` (gerenciar webhooks)
4. Copie o token — ele começa com `ghp_`

---

## 3. Configurando o GitHub no Jenkins

### 3.1 Adicionar Credenciais
```
Manage Jenkins
  └── Credentials
        └── System
              └── Global credentials
                    └── Add Credentials
                          ├── Kind: Username with password
                          ├── Username: seu-login-github
                          ├── Password: ghp_SEU_TOKEN
                          └── ID: github-credentials
```

### 3.2 Configurar GitHub Server
```
Manage Jenkins
  └── System
        └── GitHub
              └── Add GitHub Server
                    ├── Name: GitHub
                    ├── API URL: https://api.github.com
                    └── Credentials: github-credentials
```

Clique em **Test connection** — deve exibir `Credentials verified`.

---

## 4. Criando o Job Multibranch Pipeline

```
New Item
  └── Nome: meu-app
        └── Multibranch Pipeline

Branch Sources
  └── Add source: GitHub
        ├── Credentials: github-credentials
        └── Repository HTTPS URL: https://github.com/SEU_USUARIO/SEU_REPO

Build Configuration
  └── by Jenkinsfile (caminho: Jenkinsfile)

Scan Multibranch Pipeline Triggers
  └── ✅ Periodically if not otherwise run → 1 minute
```

Salve e clique em **Scan Multibranch Pipeline Now**.

---

## 5. Configurando o Webhook no GitHub

> O Jenkins precisa ter uma URL pública. Para testes locais, use o ngrok:
> ```bash
> ngrok http 8080
> # Copie a URL: https://xxxx.ngrok.io
> ```

```
GitHub Repo → Settings → Webhooks → Add webhook

Payload URL:    https://SEU_JENKINS/github-webhook/
Content type:   application/json
Secret:         (opcional, recomendado)
Events:         ✅ Just the push event
                ✅ Pull requests
```

Após salvar, clique em **Redeliver** para testar. O GitHub exibirá ✅ verde.

---

## 6. Secrets do GitHub Actions

```
GitHub Repo → Settings → Secrets and variables → Actions

JENKINS_URL       https://SEU_JENKINS
JENKINS_USER      admin
JENKINS_TOKEN     (gerado em: User → Configure → API Token)
JENKINS_JOB_NAME  meu-app/main
```

### Gerando o API Token no Jenkins:
```
Jenkins → [seu usuário] → Configure → API Token → Add new Token
```

---

## 7. Testando a Integração

```bash
# Faça um commit e push
git checkout -b feature/teste-jenkins
echo "# teste" >> README.md
git add . && git commit -m "test: testando integração Jenkins"
git push origin feature/teste-jenkins
```

Verifique:
- ✅ Webhook disparou (GitHub → Settings → Webhooks → histórico)
- ✅ Job apareceu no Jenkins
- ✅ Status de check no commit/PR no GitHub

---

## 8. Troubleshooting

| Problema | Solução |
|----------|---------|
| Webhook retorna 403 | Verifique CSRF: `Manage Jenkins → Security → desmarque "Prevent Cross Site Request Forgery"` temporariamente para testes |
| Job não inicia | Verifique o plugin "GitHub Integration" e os logs em `Manage Jenkins → System Log` |
| Sem status no PR | Instale o plugin "GitHub Checks" e configure `Checks API` |
| `checkout scm` falha | Confirme que as credenciais têm acesso de leitura ao repositório |
