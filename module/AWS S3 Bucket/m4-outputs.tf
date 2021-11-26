output "arn" {
    description = "ARN of the bucket"
    value = aws_s3_bucket.MyS3.arn
}

output "name" {
    description = "Name of the Bucket"
    value = aws_s3_bucket.MyS3.id
}