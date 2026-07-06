# Athena SQL

Table DDL and analysis queries, added alongside the Glue catalog implementation:

- `ddl/` — external table definitions over the S3 raw/curated prefixes
  (partition projection on `station`/`date` to avoid `MSCK REPAIR`).
- `analysis/` — example partition-pruned queries (daily aggregates, station
  comparisons) demonstrating cost-aware scanning.
