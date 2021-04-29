#creates a new iam role
resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_stream_assume_role.json
}

#attach s3 bucket access policy
resource "aws_iam_role_policy" "kinesis_firehose_access_bucket_policy" {
  name   = "kinesis_firehose_access_bucket_policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy.json
}

#attach send logs to cloudwatch policy
resource "aws_iam_role_policy" "kinesis_firehose_send_logs_to_cw_policy" {
  name   = "kinesis_firehose_send_logs_to_cw_policy"
  role   = aws_iam_role.firehose_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_cw_policy.json
}

resource "aws_kinesis_firehose_delivery_stream" "fh_stream" {
  name        = var.kinesis_firehose_stream_name
  destination = "s3"
  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.bucket_arn
    buffer_size        = 1
    buffer_interval    = 60
    cloudwatch_logging_options {
      enabled = true
      log_group_name = "/aws/kinesisfirehose/${var.kinesis_firehose_stream_name}"
      log_stream_name = "S3Delivery"
    }
  }
}

