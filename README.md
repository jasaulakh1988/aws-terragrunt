# aws-terragrunt

.
├── global/
│   ├── terragrunt.hcl               # Global Terragrunt config (providers, remote state config, backend configuration)
│   ├── provider.tf                  # Global provider configuration (AWS provider version)
│   └── variables.tf                 # Global variables that are reused across environments
├── shared/                          # Shared resources across environments (e.g., Route 53, CloudFront, etc.)
│   ├── route53/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── cloudfront/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── s3/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── environments/
    ├── dev/
    │   ├── terragrunt.hcl            # Environment-specific config for dev
    │   ├── network/
    │   │   └── terragrunt.hcl        # Module-specific Terragrunt config for `network`
    │   ├── compute/
    │   │   └── terragrunt.hcl        # Module-specific Terragrunt config for `compute`
    │   └── iam/
    │       └── terragrunt.hcl        # Module-specific Terragrunt config for `iam`
    └── prod/
        ├── terragrunt.hcl            # Environment-specific config for prod
        ├── network/
        │   └── terragrunt.hcl        # Module-specific Terragrunt config for `network`
        ├── compute/
        │   └── terragrunt.hcl        # Module-specific Terragrunt config for `compute`
        └── iam/
            └── terragrunt.hcl        # Module-specific Terragrunt config for `iam`

