module "s3bucket-for-sf" {
  source = "./modules/s3bucket-for-sf"
  s3_bucket_name = var.twi_s3_bucket_name
}

module "kinesis-setup" {
  source = "./modules/kinesis-setup"
  bucket_arn = module.s3bucket-for-sf.arn
  kinesis_firehose_stream_name = var.twi_kinesis_firehose_stream_name
}

module "iam-user-for-sf" {
  source = "./modules/iam-user-for-sf"
  iam_username = var.iam_username_for_sf
  s3bucket_arn = module.s3bucket-for-sf.arn
}

module "snowflake-setup" {
  source = "./modules/snowflake-setup"
  aws_access_key_id = module.iam-user-for-sf.id
  aws_secret_access_key = module.iam-user-for-sf.secret
  external_s3_bucket = module.s3bucket-for-sf.bucket
}

resource "aws_s3_bucket_notification" "bucket_notification_to_sqs" {
  bucket = module.s3bucket-for-sf.id
  queue {
    queue_arn     = module.snowflake-setup.sqs_4_snowpipe
    events        = ["s3:ObjectCreated:*"]
  }
}

