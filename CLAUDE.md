# CLAUDE.md — aws-serverless-etl

> Universal git, code and Python rules live in the workspace files
> (`../../CLAUDE.md`, `../.claude/rules/python.md`). This file adds
> project-specific rules and context only.

## What this project is

Small, free-tier AWS serverless pipeline: AEMET weather → Lambda ingest → S3
(partitioned raw) → Step Functions orchestration → Glue Catalog + Athena. The
secondary-cloud project of the upskill plan
(`workspace/wiki/learning/data-engineer-upskill-plan.md`, P3) — breadth evidence for
AWS-stack offers (Accenture/Logicalis style), deliberately kept smaller than the Azure
flagship (`../spain-energy-lakehouse`).

## Plan — read before building

**`docs/PROJECT-PLAN.md`** — 4 phases with tasks, done criteria and cost notes; update
its status table as phases advance. Keep the "deliberately small" scope: if a feature
belongs in a bigger platform, it belongs in `spain-energy-lakehouse`, not here.

## Branching model

develop-flow (workspace standard): `feature/*` off `develop` → merge to `develop`;
`develop` → `main` only via PR after Gonzalo's review. Suggested reusable branches:
`feat/ingest` (Phases 1–2), `feat/catalog` (Phase 3).

## Non-negotiable project rules

- **$0 target**: everything inside the AWS free tier; no Glue crawlers, no Secrets
  Manager, no NAT gateways. Any resource with a standing cost needs an explicit
  decision first. AWS Budgets alert at $5.
- **Nothing fake**: no committed artifacts (ASL JSON, DDL) for resources that never
  ran. Design-only content is labeled as such.
- **Least-privilege IAM** is part of the portfolio evidence — no wildcard actions or
  resources; every statement justifiable.
- **Secrets**: AEMET key via Terraform variable → Lambda env var (documented
  free-tier trade-off); never committed. `.env`/`*.local.tfvars` are gitignored.
- **No datasets in git** (`data/`, `*.csv`, `*.parquet` gitignored); test fixtures
  tiny and synthetic.
- Business logic lives typed + tested in `src/aemet_etl/`; Lambda handlers stay thin.

## Key commands

```powershell
uv sync
uv run ruff format .; uv run ruff check .; uv run mypy; uv run pytest   # quality gate (same as CI)
cd infra\terraform; terraform fmt -recursive; terraform validate
```

## Reporting changes

After completing any change, finish with a detailed numbered list of steps Gonzalo can
follow to verify it himself — exact PowerShell commands from the repo root, consoles/
URLs to check, and what a correct result looks like. Call out anything not
self-verified (e.g. deployed AWS runs needing his credentials).
