resource "aws_s3_bucket" "twi_s3_bucket" {
  bucket = var.s3_bucket_name
  acl = "private"
  tags = {
    Name = var.s3_bucket_name
  }
  force_destroy = true
}

output "arn" {
  value = aws_s3_bucket.twi_s3_bucket.arn
}

output "id" {
  value = aws_s3_bucket.twi_s3_bucket.id
}

output "bucket" {
  value = aws_s3_bucket.twi_s3_bucket.bucket
}
