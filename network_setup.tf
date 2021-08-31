resource "aws_vpc" "DWUW2NPVPC-Non-Prod-VPC" {
  provider             = aws.region-primary
  cidr_block           = "10.17.96.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = false
  tags = {
    Environment = "Non-Prod"
    Name        = "DWUW2NPVPC - Non-Prod VPC"
  }
}

#Get all available AZ's in VPC for primary region
data "aws_availability_zones" "azs" {
  provider = aws.region-primary
  state    = "available"
}

resource "aws_subnet" "DWUW2NPPVSN-Private-Zone" {
  provider          = aws.region-primary
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  cidr_block        = "10.17.96.128/25"

  tags = {
    Environment = "Non-Prod"
    Name        = "DWUW2NPPVSN - Private Zone"
    Zone        = "Private"
  }
}
resource "aws_subnet" "DWUW2NPPBSN-Public-Zone" {
  provider          = aws.region-primary
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  cidr_block        = "10.17.96.0/25"

  tags = {
    Environment = "Non-Prod"
    Name        = "DWUW2NPPBSN - Public Zone"
    Zone        = "Public"
  }
}

#Create management subnet in us-west-2
resource "aws_subnet" "DWUW2NPMGTSN-MGMT-Zone" {
  provider   = aws.region-primary
  vpc_id     = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  cidr_block = "10.17.97.0/25"

  tags = {
    Zone        = "Management"
    Name        = "DWUW2NPMGTSN - MGMT Zone"
    Environment = "Non-Prod"
  }
}

#Create NAT subnet in us-west-2
resource "aws_subnet" "DWUW2NPNGSN-Nat-Zone" {
  provider   = aws.region-primary
  vpc_id     = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  cidr_block = "10.17.97.128/25"
  tags = {
    Zone        = "Nat Gateway"
    Name        = "DWUW2NPNGSN - Nat Zone"
    Environment = "Non-Prod"
  }
}

# aws_ec2_client_vpn_endpoint.DWUW2NPCVPN-NonProd:
resource "aws_ec2_client_vpn_endpoint" "DWUW2NPCVPN-NonProd" {
  client_cidr_block      = "20.0.0.0/16"
  description            = "DWUW2NPCVPN-NonProd"
  server_certificate_arn = "arn:aws:acm:us-west-2:201458125187:certificate/8210dda3-0c52-49c1-b10f-cb4d330d7f37"
  split_tunnel           = true
  tags = {
    Name = "DWUW2NPCVPN-NonProd"
  }
  tags_all = {
    Name = "DWUW2NPCVPN-NonProd"
  }
  transport_protocol = "udp"

  authentication_options {
    root_certificate_chain_arn = "arn:aws:acm:us-west-2:201458125187:certificate/8210dda3-0c52-49c1-b10f-cb4d330d7f37"
    type                       = "certificate-authentication"
  }

  connection_log_options {
    cloudwatch_log_group  = "OpenVPNLogGroup-NonProd"
    cloudwatch_log_stream = "clientvpnlog"
    enabled               = true
  }
}

resource "aws_acm_certificate" "DWUW2PNPCC-NonProd" {
  options {
    certificate_transparency_logging_preference = "DISABLED"
  }
  tags = {
    Name = "DWUW2PNPCC-NonProd"
  }
}

resource "aws_acm_certificate" "DWUW2PNPSC-NonProd" {
  options {
    certificate_transparency_logging_preference = "DISABLED"
  }
  tags = {
    Name = "DWUW2PNPSC-NonProd"
  }
}

resource "aws_eip" "DWUW2NPNG-Nat-IP" {
  vpc = true
  tags = {
    Name = "DWUW2NPNG-Nat-IP"
  }
}

resource "aws_internet_gateway" "DWUW2NPIG-Non-Prod-IG" {
  provider = aws.region-primary
  vpc_id   = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  tags = {
    Environment = "Non-Prod"
    Name        = "DWUW2NPIG - Non-Prod IG"
  }
}

resource "aws_nat_gateway" "DWUW2NPNG-Non-Prod-NG" {
  #  connectivity_type = "public"
  subnet_id     = aws_subnet.DWUW2NPNGSN-Nat-Zone.id
  allocation_id = aws_eip.DWUW2NPNG-Nat-IP.id
  tags = {
    Environment = "Non-Prod"
    Name        = "DWUW2NPNG - Non-Prod NG"
  }
}


resource "aws_route_table" "DWUW2NPPBRT-NP-Public-RT" {
  provider = aws.region-primary
  vpc_id   = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DWUW2NPIG-Non-Prod-IG.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name        = "DWUW2NPPBRT - NP Public RT"
    Environment = "Non-Prod"
  }
}

resource "aws_route_table" "DWUW2NPPVRT-NP-Private-RT" {
  provider = aws.region-primary
  vpc_id   = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.DWUW2NPNG-Non-Prod-NG.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name        = "DWUW2NPPVRT - NP Private RT"
    Environment = "Non-Prod"
  }
}


resource "aws_route_table_association" "DWUW2NPPVRT-Private-RT-Subnets" {
  subnet_id      = aws_subnet.DWUW2NPPVSN-Private-Zone.id
  route_table_id = aws_route_table.DWUW2NPPVRT-NP-Private-RT.id
}


resource "aws_route_table_association" "DWUW2NPPBSN-Public-RT-Subnets" {
  subnet_id      = aws_subnet.DWUW2NPPBSN-Public-Zone.id
  route_table_id = aws_route_table.DWUW2NPPBRT-NP-Public-RT.id
}


resource "aws_route_table_association" "DWUW2NPPBSN-MGMT-RT-Subnets" {
  subnet_id      = aws_subnet.DWUW2NPMGTSN-MGMT-Zone.id
  route_table_id = aws_route_table.DWUW2NPPBRT-NP-Public-RT.id
}
resource "aws_route_table_association" "DWUW2NPPBSN-Nat-RT-Subnets" {
  subnet_id      = aws_subnet.DWUW2NPNGSN-Nat-Zone.id
  route_table_id = aws_route_table.DWUW2NPPBRT-NP-Public-RT.id
}

# aws_security_group.DWUW2NPMGMTSG-Non-Prod:
resource "aws_security_group" "DWUW2NPMGMTSG-Non-Prod" {
  description = "AWS Non-Prod VPN Client Security Group to manage "
  egress = [
    {
      cidr_blocks = [
        "10.156.180.0/22",
      ]
      description      = "Oracle Non-Prod Connectivity - DBAs VPC 2"
      from_port        = 1521
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 1521
    },
    {
      cidr_blocks = [
        "10.153.96.0/24",
      ]
      description      = "SQL Non-Prod Connectivity - DBAs VPC 2 - Transworks"
      from_port        = 1433
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 1433
    },
    {
      cidr_blocks = [
        "10.156.180.0/22",
      ]
      description      = "SQL Non-Prod Connectivity - DBAs VPC 1"
      from_port        = 1433
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 1433
    },
    {
      cidr_blocks = [
        "10.17.96.0/20",
      ]
      description      = "Ping"
      from_port        = -1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "icmp"
      security_groups  = []
      self             = false
      to_port          = -1
    },
    {
      cidr_blocks = [
        "10.17.96.0/20",
      ]
      description      = "All devices in VPC"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "10.17.96.165/32",
      ]
      description      = "Shah-Admin-Wks"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "10.17.96.203/32",
      ]
      description      = "jjf_workstation"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
  ]
  ingress = []
  name    = "DWUW2NPMGMTSG - Non-Prod"
  tags = {
    "Environment" = "Non-Prod"
    "Service"     = "VPN Client"
  }
  tags_all = {
    "Environment" = "Non-Prod"
    "Service"     = "VPN Client"
  }
  vpc_id = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id
  timeouts {}
}

resource "aws_security_group" "SSH_Access_From_VPN_Client" {
  description = "SSH Access from Oregon Non-Prod VPN"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks      = []
      description      = ""
      from_port        = -1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "icmp"
      security_groups = [
        "sg-041c3f968ae727925",
      ]
      self    = false
      to_port = -1
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups = [
        "sg-041c3f968ae727925",
      ]
      self    = false
      to_port = 22
    },
  ]
  name     = "SSH_Access_From_VPN_Client"
  tags     = {}
  tags_all = {}
  vpc_id   = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id

  timeouts {}
}

resource "aws_security_group" "SSH_Access_From_VPC_Clients" {
  description = "SSH Access from Oregon Non-Prod VPC"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "10.17.96.128/25",
      ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = -1
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "icmp"
      security_groups  = []
      self             = false
      to_port          = -1
    },
  ]
  name     = "SSH_Access_From_VPC_Clients"
  tags     = {}
  tags_all = {}
  vpc_id   = aws_vpc.DWUW2NPVPC-Non-Prod-VPC.id

  timeouts {}
}
