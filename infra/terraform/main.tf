resource "aws_s3_bucket" "lake" {
  bucket_prefix = "${var.prefix}-lake-"
}

resource "aws_s3_bucket_public_access_block" "lake" {
  bucket                  = aws_s3_bucket.lake.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_glue_catalog_database" "this" {
  name = replace("${var.prefix}-db", "-", "_")
}

# Lambda ingest, Step Functions state machine and IAM roles are added with the
# first pipeline implementation (see README roadmap) — no placeholder resources
# are deployed before their code exists.
