resource "aws_s3_bucket" "terraform_state" {
    bucket = "audit-notes-service13072026"
    force_destroy = true
}

resource "aws_s3_bucket_versioning" "state_versioning" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S" # S from string
  }
}


