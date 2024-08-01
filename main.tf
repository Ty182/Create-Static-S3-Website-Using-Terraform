provider "aws" {
  region = "<YOUR-REGION>"
}

# creates an s3 bucket
resource "aws_s3_bucket" "bucket1" {
  bucket = "<YOUR-BUCKET-NAME>"
}

# enables public access to the bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# creates a bucket policy that allows public read access
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket1.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.bucket1.arn}/*",
      },
    ],
  })
}

# uploads the index.html file to the bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.bucket1.id
  key          = "index.html"          # the bucket object name
  source       = "index.html"          # the file to upload
  content_type = "text/html"           # set the content type so the browser knows how to render the file
  source_hash  = filemd5("index.html") # enables automatic updates when the file changes
}

# configures the bucket to host a static website
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.bucket1.id
  index_document {
    suffix = "index.html"
  }
}

# outputs the website URL
output "website_url" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
