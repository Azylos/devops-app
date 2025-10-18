# Architecture CI/CD - DevOps App

## Vue d'ensemble du pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                         PUSH / PULL REQUEST                      │
│                      (branches: main, develop)                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PHASE 1: TESTS & LINT                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  test-backend   │  │  lint-backend   │  │ test-frontend   │ │
│  │                 │  │                 │  │                 │ │
│  │ • Python 3.11   │  │ • flake8        │  │ • Node.js 18    │ │
│  │ • pytest        │  │ • PEP 8         │  │ • syntax check  │ │
│  │ • coverage      │  │ • quality       │  │ • npm ci        │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└────────────────────────────┬────────────────────────────────────┘
                             │
                   ┌─────────┴─────────┐
                   │   All tests OK?   │
                   └─────────┬─────────┘
                             │ YES
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: BUILD DOCKER                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              build-docker (matrix strategy)                 │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  Backend Image              Frontend Image                  │ │
│  │  • Docker buildx            • Docker buildx                 │ │
│  │  • Cache layers             • Cache layers                  │ │
│  │  • Multi-platform           • Multi-platform                │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                 PHASE 3: INTEGRATION TESTS                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              docker-compose up --build                      │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  Test 1: Backend health     (curl localhost:8000)          │ │
│  │  Test 2: Frontend health    (curl localhost:3000)          │ │
│  │  Test 3: API /articles      (JSON validation)              │ │
│  │  Test 4: Database           (PostgreSQL query)             │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   PHASE 4: SECURITY SCAN                         │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐                  ┌─────────────────┐      │
│  │  Trivy Backend  │                  │ Trivy Frontend  │      │
│  │                 │                  │                 │      │
│  │ • CVE scan      │                  │ • CVE scan      │      │
│  │ • Dependencies  │                  │ • Dependencies  │      │
│  │ • SARIF report  │                  │ • SARIF report  │      │
│  └────────┬────────┘                  └────────┬────────┘      │
│           │                                    │               │
│           └────────────┬───────────────────────┘               │
│                        ▼                                        │
│           GitHub Security Dashboard                            │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  All checks OK? │
                    └────────┬────────┘
                             │ YES
                             ▼
                    ┌─────────────────┐
                    │   MERGE / OK    │
                    └─────────────────┘
```

## Pipeline de Release

```
┌─────────────────────────────────────────────────────────────────┐
│                      GIT TAG (v*.*.*)                            │
│                    git push origin v1.0.0                        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CREATE GITHUB RELEASE                        │
├─────────────────────────────────────────────────────────────────┤
│  • Création automatique de la release                            │
│  • Extraction de la version depuis le tag                        │
│  • Génération des release notes                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                  PUBLISH DOCKER IMAGES                           │
├─────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              GitHub Container Registry (ghcr.io)            │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │  Backend:                           Frontend:               │ │
│  │  • ghcr.io/user/repo/backend:1.0.0  • ghcr.io/.../frontend │ │
│  │  • ghcr.io/user/repo/backend:latest • :1.0.0               │ │
│  │                                     • :latest               │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ IMAGES PUBLIQUES │
                    │   DISPONIBLES    │
                    └─────────────────┘
```

## Déclencheurs (Triggers)

### Pipeline CI
- **Push** sur `main` ou `develop`
- **Pull Request** vers `main` ou `develop`

### Pipeline Release
- **Tag** avec format `v*.*.*` (ex: v1.0.0, v2.1.3)

## Jobs et dépendances

```
test-backend ─┐
              ├─→ build-docker ─→ integration-test ─→ security-scan
lint-backend ─┤                                          │
              │                                          │
test-frontend┘                                          │
                                                         ▼
                                                    Merge OK
```

## Temps d'exécution estimé

| Phase                | Durée estimée |
|---------------------|---------------|
| Tests Backend       | ~30s          |
| Lint Backend        | ~15s          |
| Tests Frontend      | ~20s          |
| Build Docker        | ~2-3min       |
| Integration Tests   | ~1min         |
| Security Scan       | ~1min         |
| **Total**           | **~5-6min**   |

## Cache et optimisations

### Python (pip)
```yaml
- uses: actions/setup-python@v5
  with:
    cache: 'pip'
```

### Node.js (npm)
```yaml
- uses: actions/setup-node@v4
  with:
    cache: 'npm'
```

### Docker Layers
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```

## Artefacts générés

1. **Coverage Reports** (backend)
   - Format: XML (Codecov)
   - Upload automatique vers Codecov

2. **SARIF Reports** (security)
   - Trivy scan results
   - Upload vers GitHub Security

3. **Docker Images** (release)
   - GitHub Container Registry
   - Tags: version + latest

## Variables d'environnement

| Variable              | Description                    | Source              |
|----------------------|--------------------------------|---------------------|
| `GITHUB_TOKEN`       | Token d'authentification       | Auto (GitHub)       |
| `REGISTRY`           | Registry Docker                | Workflow (ghcr.io)  |
| `BACKEND_IMAGE_NAME` | Nom image backend              | Workflow            |
| `FRONTEND_IMAGE_NAME`| Nom image frontend             | Workflow            |

## Sécurité

### Scans effectués

1. **Trivy** - Vulnérabilités CVE
   - Scan du filesystem
   - Dépendances Python (pip)
   - Dépendances Node.js (npm)

2. **Flake8** - Qualité du code
   - PEP 8 compliance
   - Complexité cyclomatique
   - Erreurs de syntaxe

### Rapports

Tous les rapports de sécurité sont disponibles dans :
- GitHub Security → Code scanning alerts

## Notifications

Les notifications sont envoyées automatiquement :
- ✅ Succès du pipeline
- ❌ Échec du pipeline
- 📦 Nouvelle release créée

Visible dans :
- GitHub Actions tab
- Pull Request checks
- Email (configurable)

## Améliorer le pipeline

### Prochaines étapes

1. **Tests E2E** avec Playwright/Cypress
2. **Performance tests** avec k6
3. **Déploiement automatique** vers staging
4. **Notifications Slack/Discord**
5. **Rollback automatique** en cas d'échec

### Métriques à suivre

- ✅ Code coverage (>80%)
- ✅ Build time (<5min)
- ✅ Test success rate (100%)
- ✅ Vulnerabilities (0 critical)
