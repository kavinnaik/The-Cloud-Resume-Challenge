import json
import os
from typing import Any, Dict

import boto3
from botocore.exceptions import ClientError

TABLE_NAME = os.environ.get("TABLE_NAME", "")
PARTITION_KEY = "id"
COUNTER_KEY = "visits"
ITEM_ID = "global"

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME) if TABLE_NAME else None


def _build_response(status_code: int, body: Dict[str, Any]) -> Dict[str, Any]:
  """Helper to build an HTTP response with CORS enabled."""
  return {
    "statusCode": status_code,
    "headers": {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET,OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
    "body": json.dumps(body),
  }


def handler(event, _context):
  # Pre-flight for CORS
  if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
    return _build_response(204, {})

  if not table:
    return _build_response(
      500,
      {"message": "TABLE_NAME environment variable is not set."},
    )

  try:
    # Atomically increment the visitor counter and return the new value.
    result = table.update_item(
      Key={PARTITION_KEY: ITEM_ID},
      UpdateExpression=f"ADD {COUNTER_KEY} :inc",
      ExpressionAttributeValues={":inc": 1},
      ReturnValues="UPDATED_NEW",
    )

    count = int(result["Attributes"].get(COUNTER_KEY, 0))
    return _build_response(200, {"count": count})
  except ClientError as exc:
    # Log the whole exception for CloudWatch but keep the response user-friendly.
    print(f"Error updating visitor count: {exc}")
    return _build_response(500, {"message": "Failed to update visitor count."})


