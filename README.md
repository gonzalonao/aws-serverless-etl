# AWS Serverless ETL

Serverless batch pipeline on the AWS free tier: Spanish weather observations (AEMET
OpenData) ingested by Lambda, orchestrated with Step Functions, cataloged in Glue and
queried with Athena — all provisioned with Terraform and gated by CI.

![Python](https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20Lambda%20%7C%20Step%20Functions%20%7C%20Athena-FF9900?logo=amazonwebservices&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?logo=terraform&logoColor=white)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)

> **Status: scaffold / in active development.** Structure, IaC skeleton and CI are in
> place; pipeline implementation follows the roadmap below.

## What this demonstrates

A deliberately small, well-engineered AWS counterpart to my Azure work
([spain-energy-lakehouse](https://github.com/gonzalonao/spain-energy-lakehouse)):

- **Ingestion** — Lambda pulling AEMET OpenData (free API key) into S3, partitioned
  `raw/station=/date=`, idempotent re-runs.
- **Orchestration** — Step Functions state machine: ingest → validate → partition
  registration, with retries and catch states.
- **Catalog & query** — Glue Data Catalog table over S3, queried with Athena
  (partition-pruned SQL kept in `sql/athena/`).
- **Engineering practice** — Terraform IaC, GitHub Actions CI (lint, types, tests,
  `terraform validate`), no console-clicked resources.

## Architecture

```mermaid
flowchart LR
    A[AEMET OpenData API] -->|Lambda ingest| B[(S3 raw<br/>partitioned)]
    B --> C{Step Functions<br/>validate + register}
    C --> D[Glue Data Catalog]
    D --> E[Athena SQL]
```

## Repository layout

```
infra/terraform/     S3, Lambda, Step Functions, Glue, IAM — all IaC
src/lambdas/         Lambda handlers (typed, tested)
sql/athena/          table DDL and analysis queries
tests/               pytest suite
```

## Getting started

```powershell
git clone https://github.com/gonzalonao/aws-serverless-etl.git
cd aws-serverless-etl
uv sync
uv run pytest
```

Deployment requires an AWS account (free tier) and an AEMET API key:

```powershell
cd infra\terraform
terraform init
terraform plan
```

## Roadmap

- [x] Scaffold: structure, Terraform/CI skeletons
- [ ] Lambda ingest: AEMET observations → S3 raw, idempotent partitions
- [ ] Step Functions: orchestration with retries + failure notifications
- [ ] Glue catalog + Athena DDL and example analyses
- [ ] Cost notes: staying inside the free tier, budget alarm

## Author

**Gonzalo López Crespo** — [LinkedIn](https://linkedin.com/in/gonzalolopezcrespo) · [GitHub](https://github.com/gonzalonao)
