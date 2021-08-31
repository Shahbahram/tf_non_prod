# aws_instance.Shah_Admin_Wks:
resource "aws_instance" "Shah_Admin_Wks" {
  ami                                  = "ami-0b28dfc7adc325ef4"
  associate_public_ip_address          = false
  availability_zone                    = "us-west-2a"
  cpu_core_count                       = 1
  cpu_threads_per_core                 = 1
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  iam_instance_profile                 = "Wdtvs_Terraform_Role"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.micro"
  key_name                             = "Shah-Admin-Wks"
  monitoring                           = false
  private_ip                           = "10.17.96.165"
  secondary_private_ips                = []
  security_groups                      = []
  source_dest_check                    = true
  subnet_id                            = "subnet-0b1fd8ac496440907"
  tags = {
    "Name" = "Shah-Wks"
  }
  tags_all = {
    "Name" = "Shah-Wks"
  }
  tenancy = "default"
  vpc_security_group_ids = [
    "sg-01777a211f536aedb",
  ]

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sdb"
    encrypted             = true
    iops                  = 100
    kms_key_id            = "arn:aws:kms:us-west-2:201458125187:key/5b2d2deb-640b-4cce-813d-54eac5d6c846"
    tags                  = {}
    throughput            = 0
    volume_size           = 30
    volume_type           = "gp2"
  }

  enclave_options {
    enabled = false
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    iops                  = 100
    kms_key_id            = "arn:aws:kms:us-west-2:201458125187:key/5b2d2deb-640b-4cce-813d-54eac5d6c846"
    tags                  = {}
    throughput            = 0
    volume_size           = 30
    volume_type           = "gp2"
  }

  timeouts {}
}
