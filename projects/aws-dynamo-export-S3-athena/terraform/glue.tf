# O Database no Athena/Glue
resource "aws_glue_catalog_database" "this" {
  name = "${local.project_name}-db"
}
