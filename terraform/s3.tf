resource "aws_s3_bucket_object" "artifacts" {
  for_each = fileset("${var.source_dir}/hivemq-artifacts", "**/*")

  bucket = var.s3_bucket
  source = "${var.source_dir}/hivemq-artifacts/${each.value}"

  key    = "hivemq-artifacts/${each.value}"
  etag   = filemd5("${var.source_dir}/hivemq-artifacts/${each.value}")
}