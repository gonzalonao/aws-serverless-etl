# Project plan — aws-serverless-etl

Deliberately small AWS counterpart to `spain-energy-lakehouse`: working AWS knowledge
(S3, Lambda, Step Functions, Glue, Athena, IAM) for the Accenture/Logicalis-style
offers, entirely inside the free tier. Same source domain as the Azure project's Phase
E3 (AEMET weather) — a deliberate compare-the-clouds portfolio angle.

| Phase | Scope | Status |
|---|---|---|
| 1 | Lambda ingest: AEMET → S3 raw, idempotent partitions | Not started |
| 2 | Step Functions orchestration + failure handling | Not started |
| 3 | Glue Catalog + Athena queries | Not started |
| 4 | Wrap-up: cost notes, README evidence, teardown discipline | Not started |

Definition of done per phase: merged to `develop` via a `feat/*` branch, CI green,
done criteria met, README roadmap ticked, wiki note updated
(`wiki/learning/aws-fundamentals.md`).

---

## Phase 1 — Lambda ingest

**Goal:** a scheduled Lambda pulling AEMET observations into S3, partitioned and
idempotent — the serverless ingestion pattern.

1. AEMET OpenData API key (free, instant). Store in AWS Secrets Manager? **No** —
   free tier has no Secrets Manager allowance; use a Lambda environment variable
   set by Terraform from a `TF_VAR` (documented trade-off; note what production
   would do: Secrets Manager/SSM SecureString).
2. Handler `src/lambdas/ingest_aemet/handler.py` (typed, thin): AEMET's two-step API
   (metadata request → temporary data URL) for hourly observations of a fixed
   station list; write JSON to
   `s3://…/raw/observations/station=<id>/date=YYYY-MM-DD/hour=HH.json`.
   Same-key overwrite on re-run = idempotent. Business logic in `src/aemet_etl/`
   (unit-tested with stubbed HTTP + moto/S3 stub); handler is glue only.
3. Package: Terraform `archive_file` zip (no container needed at this size);
   `aws_lambda_function` + EventBridge schedule rule (hourly), IAM role scoped to the
   single bucket prefix (least-privilege is the evidence — no `s3:*`).
4. Structured logging (JSON to CloudWatch); one custom metric (records ingested).

**Done criteria:** a week of unattended hourly partitions in S3; re-invoking an hour
creates no duplicates; IAM policy passes the "why is each statement here" question;
cold start/timeout/memory sizing explainable without notes.

**Cost:** $0 (Lambda + EventBridge + S3 free-tier volumes).

## Phase 2 — Step Functions orchestration

**Goal:** a state machine that owns the run: ingest → validate → register, with
retry/catch — the AWS-native orchestration story to contrast with Airflow.

1. State machine (Terraform, `aws_sfn_state_machine` with the ASL JSON in
   `infra/`): `IngestObservations` (Lambda) → `ValidateBatch` (second small Lambda:
   file exists, parses, required fields, plausible ranges — the quality-gate pattern
   shared with the other projects) → `RegisterPartition` (Athena
   `ALTER TABLE ADD PARTITION` or rely on partition projection — see Phase 3;
   if projection, this state becomes a no-op and says so).
2. Error handling: `Retry` with backoff on transient AEMET failures, `Catch` →
   SNS topic (email) on terminal failure. Move the EventBridge schedule to trigger
   the state machine instead of the Lambda directly.
3. Document (short `docs/orchestration.md`): Step Functions vs Airflow vs ADF —
   when a consultancy picks which; standard vs express workflows.

**Done criteria:** a forced AEMET failure shows retries then a caught failure + email;
the happy path runs green on schedule; standard-vs-express and states-language basics
explainable without notes.

**Cost:** ~$0 (4k free state transitions/month covers hourly runs; SNS email free).

## Phase 3 — Glue Catalog + Athena

**Goal:** queryable lake — catalog the raw data and demonstrate cost-aware SQL.

1. Glue table over the raw prefix (Terraform `aws_glue_catalog_table`): JSON SerDe,
   **partition projection** on `station`/`date`/`hour` (no crawler, no MSCK — document
   why projection beats crawlers for predictable layouts; crawlers cost money and are
   the naive answer).
2. `sql/athena/ddl/` — the table DDL as committed SQL; `sql/athena/analysis/` —
   3–4 real queries (daily temperature aggregates by station, hottest-hour windows —
   window functions on record, partition-pruned scans).
3. Optional curated layer: a CTAS query producing Parquet
   (`curated/observations_daily/`) to show columnar-conversion cost math (scanned-MB
   before vs after — put the numbers in the README).

**Done criteria:** Athena answers the analysis queries scanning only pruned
partitions (show scanned-bytes evidence); JSON-vs-Parquet scan cost documented with
real numbers; Glue catalog/crawler/projection trade-offs explainable without notes.

**Cost:** Athena $5/TB scanned — at these volumes, cents. Avoid crawlers ($) entirely.

## Phase 4 — Wrap-up

1. `docs/cost-notes.md`: actual spend (target: $0), what the free tier absorbed,
   what a production version would cost.
2. README: architecture section updated to as-built, screenshots (state machine
   graph, Athena results), scanned-bytes numbers.
3. AWS Budgets alert at $5 (should never fire) — evidence of guardrails.
4. Teardown: `terraform destroy` clean; repo remains the reproducible artifact.

**Done criteria:** a stranger with an AWS account and an AEMET key can
`terraform apply` and have the pipeline running in < 30 min (test this claim against
the README instructions).
