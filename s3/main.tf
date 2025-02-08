resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "bucket" {
  bucket        = length(var.bucket_name) > 0 ? var.bucket_name : "bucket-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = var.bucket_policy
}
