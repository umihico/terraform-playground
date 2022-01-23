data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region  = coalesce(var.region, data.aws_region.current.name)
  secrets = { for m in var.secrets : m["name"] => m["encrypted_value"] }
}

resource "local_file" "temp" {
  for_each = local.secrets
  content  = each.value
  filename = "${path.module}/${each.key}.encrypted.txt"
}

resource "null_resource" "executor" {
  depends_on = [
    local_file.temp
  ]
  for_each = local.secrets
  triggers = {
    value   = md5(local_file.temp[each.key].content)
    region  = local.region
    profile = coalesce(var.profile, var.STATELESS_SSM_PROFILE)
    # https://github.com/hashicorp/terraform/issues/23679
  }

  provisioner "local-exec" {
    command = join(" ", compact([
      "SECRET=$(aws kms decrypt",
      "--ciphertext-blob file://${path.module}/${each.key}.encrypted.txt",
      "--output json",
      "--output text",
      "--query Plaintext",
      "--region ${self.triggers.region}",
      "--profile ${self.triggers.profile}",
      "| base64 --decode)",
      ";",
      "aws ssm put-parameter",
      "--name ${each.key}",
      "--type 'SecureString'",
      "--overwrite",
      "--value \"$SECRET\"",
      "--region ${self.triggers.region}",
      "--profile ${self.triggers.profile}",
      ";",
      "rm ${path.module}/${each.key}.encrypted.txt",
      "# ${var.exec_log_suppresser}",
    ]))
  }

  provisioner "local-exec" {
    when = destroy
    command = join(" ", compact([
      "aws ssm delete-parameter",
      "--name ${each.key}",
      "--region ${self.triggers.region}",
      "--profile ${self.triggers.profile}",
    ]))
  }
}
