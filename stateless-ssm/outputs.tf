
output "aws_ssm_parameters" {
  value = { for k, v in local.secrets : k => {
    arn   = "arn:aws:ssm:${local.region}:${data.aws_caller_identity.current.account_id}:parameter/${k}"
    name  = k
    type  = "SecureString"
    value = v # encrypted
  } }
}
