include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network-private"  # Get private subnets from network-private
}

terraform {
  source = "../../../modules/core/ec2"
}

# Define multiple teams and services dynamically
inputs = {
  vpc_id         = dependency.network.outputs.vpc_id
  private_subnets = dependency.network.outputs.private_subnets  # Use the subnets from network-private
  region          = "us-east-1"
  default_subnet_id   = "subnet-047ad0dadb8200beb"

  instance_configurations = [
  {
    team_name      = "engineering"
    service        = "web"
    servicetype    = "ec2"    # Changed to 'servicetype'
    instance_type  = "t3.micro"
    ami_id         = "ami-096ea6a12ea24a797"
    count          = 1
    environment    = "dev"
    tags = {
      "Environment" = "dev"
      "ServiceType" = "ec2"   # You can keep the tag key as 'ServiceType' if desired
      "Team"        = "engineering"
    }
    root_block_device = {
      volume_size = 20         # Set the root volume size (in GB)
      volume_type = "gp2"      # General Purpose SSD
      delete_on_termination = true  # Delete the volume when the instance is terminated
    }
    ebs_block_device = [
      {
        device_name = "/dev/sdf"  # Specify the device name
        volume_size = 100         # Size in GB for additional storage
        volume_type = "gp2"       # General Purpose SSD
        delete_on_termination = true  # Automatically delete on instance termination
      }
    ]
  },
  {
    team_name      = "operations"
    service        = "app"
    servicetype    = "dbs"    # Changed to 'servicetype'
    instance_type  = "t3.large"
    ami_id         = "ami-0abcdef12345"
    count          = 0
    environment    = "dev"
    tags = {
      "Environment" = "dev"
      "ServiceType" = "dbs"   # Consistent tagging
      "Team"        = "operations"
    }
  }
]
}

