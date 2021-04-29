import os
import json
import boto3
from tweepy import OAuthHandler, Stream, StreamListener

def check_empty(varname, varval):
  if not varval:
    print("Unexpected empty Value: {0}".format(varname))
    exit(1)

#read env variables
kinesis_delivery_stream_name = os.getenv("twi_kinesis_firehose_stream_name")
check_empty("kinesis_delivery_stream_name", kinesis_delivery_stream_name)

twi_consumer_key = os.getenv("twi_consumer_key")
check_empty("twi_consumer_key", twi_consumer_key)

twi_consumer_secret = os.getenv("twi_consumer_secret")
check_empty("twi_consumer_secret", twi_consumer_secret)

twi_access_token = os.getenv("twi_access_token")
check_empty("twi_access_token", twi_access_token)

twi_access_token_secret = os.getenv("twi_access_token_secret")
check_empty("twi_access_token_secret", twi_access_token_secret)

aws_region_id = os.getenv("aws_region_id")
check_empty("aws_region_id", aws_region_id)

aws_access_key_id = os.getenv("aws_access_key_id")
check_empty("aws_access_key_id", aws_access_key_id)

aws_secret_access_key = os.getenv("aws_secret_access_key")
check_empty("aws_secret_access_key", aws_secret_access_key)

#In case you are using temporary token/creds you will need the session token
aws_session_token = os.getenv("aws_session_token")
if not aws_session_token:
  session = boto3.Session(
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    region_name=aws_region_id
  )
else:
  session = boto3.Session(
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    aws_session_token=aws_session_token,
    region_name=aws_region_id
  )

kinesis_client = session.client('firehose')

def sendToStream(data):
  response = kinesis_client.put_record(
      DeliveryStreamName = kinesis_delivery_stream_name,
      Record = {
          'Data': data.encode()
      }
  )
  return response

class StdOutListener(StreamListener):
  def on_data(self, data):
    print(data)
    response = sendToStream(data)
    return True

  def on_error(self, status):
    if status == 420:
      return False

listnr = StdOutListener()

#twitter - capture stream
auth = OAuthHandler(twi_consumer_key, twi_consumer_secret)
auth.set_access_token(twi_access_token, twi_access_token_secret)
stream = Stream(auth=auth, listener=listnr)
stream.filter(track=['cricket'])

