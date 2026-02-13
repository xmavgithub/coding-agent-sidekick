# GitHub Setup Runbook

## 1. Initialize local repository
```bash
scripts/init-repo.sh
```

If the project is an existing codebase, bootstrap baseline once:
```bash
make bootstrap-existing-baseline SOURCE_PATH="."
```

## 2. Create GitHub repository and set remote
```bash
git remote add origin <repo-url>
git push -u origin main
```

## 3. Configure branch protection on `main`
- Require pull requests.
- Block merge without status checks.
- Require review.
- Block force pushes.

## 4. Recommended required checks (Medium)
- `docs-and-style`
- `policy-check`
- `security-scan`

## 5. Security settings
- Enable secret scanning.
- Enable Dependabot alerts.
- Enable dependency graph.
