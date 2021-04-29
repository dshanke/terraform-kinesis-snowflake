locals {
  file_format = " file_format=(type='JSON')"
}

resource "snowflake_warehouse" "TWI_WH" {
  name           = "TWI_WH"
  comment        = "twitter analysis wh"
  warehouse_size = "XSMALL"
  auto_suspend   = 120
  auto_resume    = true
}

resource "snowflake_database" "TWIDB" {
  name                        = "TWIDB"
  comment                     = "Twitter DB"
  data_retention_time_in_days = 1
}

#creates a snowflake table. Notice the data type of column is a variant type which allows us to store json like data
resource "snowflake_table" "TWI_TABLE" {
  database = snowflake_database.TWIDB.name
  schema   = "PUBLIC"
  name     = "TWEETS"
  comment  = "Twitter streams data table."
  column {
    name = "tweet"
    type = "VARIANT"
  }
}
#Creates snowflake external stage from (s3) which snowpipe will read data files
#we are using aws access keys here to allow access to s3, but as mentioned earlier
#external IAM roles can be used to manage the cross account access control in a better way.
#Refer https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html
resource "snowflake_stage" "external_stage_s3" {
  name        = "TWITTER_STAGE"
  url         = join("", ["s3://", var.external_s3_bucket, "/"])
  database    = snowflake_database.TWIDB.name
  schema      = "PUBLIC"
  credentials = "AWS_KEY_ID='${var.aws_access_key_id}' AWS_SECRET_KEY='${var.aws_secret_access_key}'"
}

#create pipe to copy into the tweets table from the external stage
resource "snowflake_pipe" "snowpipe" {
  name     = "snowpipe"
  database = snowflake_database.TWIDB.name
  schema   = "PUBLIC"
  comment  = "This is the snowpipe that will consume kinesis delivery stream channelled via the sqs."
  copy_statement = join("", [
    "copy into ",
    snowflake_database.TWIDB.name, ".PUBLIC.", snowflake_table.TWI_TABLE.name,
    " from @",
    snowflake_database.TWIDB.name, ".PUBLIC.", snowflake_stage.external_stage_s3.name,
    local.file_format
  ])
  auto_ingest = true
}

output "sqs_4_snowpipe" {
  value = snowflake_pipe.snowpipe.notification_channel
}

