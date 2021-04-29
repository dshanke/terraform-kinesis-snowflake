variable "twi_s3_bucket_name" {
  type = string
  default = "damz-twi-s3-bucket-1"
}

variable "twi_kinesis_firehose_stream_name" {
  type = string
  default = "terraform-kinesis-firehose-twi-stream"
}

variable "iam_username_for_sf" {
  type = string
  default = "sfusers3ro"
}

