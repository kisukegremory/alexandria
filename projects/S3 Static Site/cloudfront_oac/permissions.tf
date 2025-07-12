resource "aws_s3_bucket_policy" "this" {
  bucket = data.terraform_remote_state.bucket.outputs.bucket_id
   policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "${data.terraform_remote_state.bucket.outputs.bucket_arn}/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "${aws_cloudfront_distribution.this.arn}"
        }
      }
    }
  ]
})
  depends_on = [ aws_cloudfront_distribution.this ]
}
