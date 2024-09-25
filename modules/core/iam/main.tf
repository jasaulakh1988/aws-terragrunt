# modules/iam/main.tf
terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# Load YAML configuration from file
locals {
  iam_config = yamldecode(file("${var.config_file_path}"))
# Default to an empty list if 'roles' is not present in the YAML
  roles = lookup(local.iam_config, "roles", [])
}

# Create IAM Groups and attach managed policies
resource "aws_iam_group" "group" {
  for_each = { for group in local.iam_config.groups : group.name => group }
  name     = each.key
}

# Attach managed policies to groups
resource "aws_iam_group_policy_attachment" "group_policies" {
  for_each = {
    for group in local.iam_config.groups : group.name => flatten([for policy in group.policies : policy])
  }
  group      = aws_iam_group.group[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value[0]}"  # Flatten and select the first element
}

# Create custom policies and attach them to groups
#resource "aws_iam_group_policy" "custom_group_policies" {
#  for_each = { for group in local.iam_config.groups : group.name => group.custom_policies if length(group.custom_policies) > 0 }
#  name     = each.value[0].name
#  group    = aws_iam_group.group[each.key].name
#  policy   = jsonencode(each.value[0].policy_document)
#}

resource "aws_iam_group_policy" "custom_group_policies" {
  for_each = { for group in local.iam_config.groups : group.name => group if contains(keys(group), "custom_policies") && length(group.custom_policies) > 0 }

  name     = each.value.custom_policies[0].name
  group    = aws_iam_group.group[each.key].name
  policy   = jsonencode(each.value.custom_policies[0].policy_document)
}


# Create IAM users and add them to groups
resource "aws_iam_user" "user" {
  for_each = { for user in local.iam_config.users : user.username => user }
  name     = each.key

  # Tagging IAM Users with team=groupname
  tags = {
    "Team" = each.value.groups[0]  # Assuming a single group per user
  }
}

resource "aws_iam_user_group_membership" "user_group" {
  for_each = { for user in local.iam_config.users : user.username => user }
  user     = aws_iam_user.user[each.key].name
  groups   = [for group in each.value.groups : aws_iam_group.group[group].name]
}

# MFA Enforcement Policy
resource "aws_iam_user_policy" "mfa_policy" {
  for_each = { for user in local.iam_config.users : user.username => user }
  name     = "${each.key}-mfa-policy"
  user     = aws_iam_user.user[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Strong Password Policy for all users
resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length    = 12
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_symbols            = true
  require_numbers            = true
  allow_users_to_change_password = true
  max_password_age           = 90
  password_reuse_prevention  = 5
}

# Access Key Rotation (Notify users to rotate keys via CloudWatch Alarms)
resource "aws_iam_access_key" "user_access_key" {
  for_each = { for user in local.iam_config.users : user.username => user if user.access_key == true }
  user     = aws_iam_user.user[each.key].name
}

# Create IAM roles with assume role policy (only if roles exist)
resource "aws_iam_role" "role" {
  for_each = { for role in local.roles : role.name => role }
  name               = each.key
  assume_role_policy = jsonencode(each.value.assume_role_policy)
}

# Attach managed policies to roles (only if roles exist)
resource "aws_iam_role_policy_attachment" "role_policies" {
  for_each = {
    for role in local.roles : role.name => flatten([for policy in role.policies : policy])
  }
  role       = aws_iam_role.role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/${each.value[0]}"  # Flatten and select the first element
}

# Outputs
output "iam_users" {
  value = [for user in aws_iam_user.user : user.name]
}

output "iam_groups" {
  value = [for group in aws_iam_group.group : group.name]
}

output "iam_roles" {
  value = [for role in aws_iam_role.role : role.name]
}

