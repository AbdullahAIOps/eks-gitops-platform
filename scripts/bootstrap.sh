#!/usr/bin/env bash
# Create the remote-state backend: an encrypted, versioned S3 bucket and a
# DynamoDB table for state locking. Run once per environment.
#
# Usage: ./scripts/bootstrap.sh abdullah-gitops-tfstate abdullah-gitops-tflocks us-east-1
set -euo pipefail

BUCKET="${1:?bucket name required}"
TABLE="${2:?lock table name required}"
REGION="${3:?region required}"

echo ">> Creating S3 state bucket: ${BUCKET} (${REGION})"
if [[ "${REGION}" == "us-east-1" ]]; then
  aws s3api create-bucket --bucket "${BUCKET}" --region "${REGION}"
else
  aws s3api create-bucket --bucket "${BUCKET}" --region "${REGION}" \
    --create-bucket-configuration LocationConstraint="${REGION}"
fi

aws s3api put-bucket-versioning --bucket "${BUCKET}" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "${BUCKET}" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'

aws s3api put-public-access-block --bucket "${BUCKET}" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo ">> Creating DynamoDB lock table: ${TABLE}"
aws dynamodb create-table \
  --table-name "${TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "${REGION}" >/dev/null 2>&1 || echo "   (lock table already exists)"

echo ">> Backend ready."
