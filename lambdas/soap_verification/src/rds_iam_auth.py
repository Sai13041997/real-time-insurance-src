import os
import boto3
import pg8000

#Env variables for RDS IAM auth connection and pg8000 connection parameters (populated via terraform at deploy time of lambda)
DB_ENDPOINT = os.environ.get("db_endpoint")
DB_NAME = os.environ.get("db_name")
DB_USER = os.environ.get("db_user")
AWS_REGION = os.environ.get("db_region")
DB_PORT = 5432


def get_rds_iam_connection():
    """
    Open a pg8000 connection using IAM auth token as the password.

    Required environment variables:
    - ENDPOINT
    - DB_NAME
    - DB_USER

    Optional environment variables:
    - DB_PORT (default: 5432)
    - AWS_REGION (default: us-east-1)
    """
    client = boto3.client("rds", region_name=AWS_REGION)
    token = client.generate_db_auth_token(
        DBHostname=DB_ENDPOINT,
        Port=DB_PORT,
        DBUsername=DB_USER,
        Region=AWS_REGION
    )

    return pg8000.connect(
        user=DB_USER,
        password=token,
        host=DB_ENDPOINT,
        port=DB_PORT,
        database=DB_NAME,
    )
