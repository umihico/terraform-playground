locals {
  env                 = yamldecode(file("env.yml"))
  test_resource_name  = "fuga"
  test_resource_value = "valval"
  test_key_value = {
    "${local.env.project_name}-key9" : "val9"
  }
}

resource "aws_kms_key" "sample" {
  description         = "${local.env.project_name}-sample-master-key"
  enable_key_rotation = true
  is_enabled          = true
}

resource "aws_kms_alias" "sample" {
  name          = "alias/sample/${local.env.project_name}"
  target_key_id = aws_kms_key.sample.key_id
}

resource "aws_ssm_parameter" "sample" {
  name   = "${local.env.project_name}-sample-parameter"
  type   = "SecureString"
  value  = "dummy-password"
  key_id = aws_kms_key.sample.key_id
  lifecycle {
    ignore_changes = [value]
  }
}

data "aws_ssm_parameter" "foo" {
  name            = aws_ssm_parameter.sample.name
  with_decryption = false
}


/*

This is example of encription.

aws kms encrypt \
  --key-id alias/sample/terraform-playground \
  --plaintext "$(echo -n 'AKIAIOSFODNN7EXAMPLE' | base64)" \
  --output text \
  --query CiphertextBlob

aws kms encrypt \
  --key-id alias/sample/terraform-playground \
  --plaintext "$(echo -n 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' | base64)" \
  --output text \
  --query CiphertextBlob

*/

module "stateless-ssm" {
  source = "./stateless-ssm"
  secrets = [
    {
      name            = "${local.env.project_name}-demo-aws-access-key-id4"
      encrypted_value = "AQICAHjYpwdfFBRxMXiUylCV5Jb/RRdaYjsUvsPiUN7kLOe9nAEzB/jOpNC8G1zLPCJCXdxDAAAAcjBwBgkqhkiG9w0BBwagYzBhAgEAMFwGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMTsUexQ2gWsqIPTkKAgEQgC/AaRljRAlkOJBLZ3aU3TlMA1HObvhBol97yz9Ti2k5ydbK16J0uqgKdyaNKtxycA=="
    },
    {
      name            = "${local.env.project_name}-demo-aws-access-secret-key4"
      encrypted_value = "AQICAHjYpwdfFBRxMXiUylCV5Jb/RRdaYjsUvsPiUN7kLOe9nAGy13OvaAk1dhzUrZ8hoaz7AAAAhzCBhAYJKoZIhvcNAQcGoHcwdQIBADBwBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDH5/NamRY2xllOuEWAIBEIBDiXNps1BfRVcPSMyV8mWbFkXdlQhE3eceKJ2YI6hBRgszsnR0CESBjgGsjN19cqTklJuGWVZ1IEJrwd7UbzE1sk3HqQ=="
    },
  ]
}
