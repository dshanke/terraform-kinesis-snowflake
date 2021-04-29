#Define a policy which will allow Kinesis Data Firehose to Assume an IAM Role
data "aws_iam_policy_document" "kinesis_firehose_stream_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

#Define a policy which will allow Kinesis Data Firehose to access your S3 bucket
data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      var.bucket_arn,
      "${var.bucket_arn}/*",
    ]
  }
}

#Define a policy which will allow Kinesis Data Firehose to send logs to cloudwatch
#The resource group can be further controlled ...for now allowing every action
data "aws_iam_policy_document" "kinesis_firehose_cw_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

