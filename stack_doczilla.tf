resource "aws_ebs_encryption_by_default" "wdtvs-encrypt" {
  enabled = true
}

resource "aws_key_pair" "linux-np" {
  provider   = aws.region-primary
  key_name   = "linux-np"
  public_key = file("~/non_prod_keys/id_rsa.pub")
}

#Create and bootstrap doczilla tomcat application  server 
resource "aws_instance" "doczilla_app" {
  provider                    = aws.region-primary
  ami                         = "ami-0c2d06d50ce30b442"
#  ami                         = "ami-0bcadaece3162039d"  Redhat 8.3 ami 
  instance_type               = "t3.large"
  key_name                    = aws_key_pair.linux-np.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.SSH_Access_From_VPC_Clients.id]
  subnet_id                   = aws_subnet.DWUW2NPPVSN-Private-Zone.id

# root disk
root_block_device {
    volume_size           = "80"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

# data disk
ebs_block_device {
    device_name           = "/dev/xvdb"
    volume_size           = "200"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
tags = {
    Name = "doczilla_app"
  }
provisioner "remote-exec" {
    inline = ["echo 'Wait until ssh is ready'"]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(pathexpand(var.private_key_path))
      host = aws_instance.doczilla_app.private_ip
    }
}

provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-primary} --instance-ids ${aws_instance.doczilla_app.id} \
&& ansible-playbook -i ${aws_instance.doczilla_app.private_ip}, ansible_templates/doczilla_app.yml
EOF
  }
}
############################################################

#Create and bootstrap doczilla nginx proxy server

resource "aws_instance" "doczilla_proxy" {
  provider                    = aws.region-primary
  ami                         = "ami-0c2d06d50ce30b442"
#  ami                         = "ami-0bcadaece3162039d"
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.linux-np.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.SSH_Access_From_VPC_Clients.id]
  subnet_id                   = aws_subnet.DWUW2NPPBSN-Public-Zone.id

# root disk
root_block_device {
    volume_size           = "80"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "doczilla_proxy"
  }
  depends_on = [aws_route_table.DWUW2NPPBRT-NP-Public-RT]

provisioner "remote-exec" {
    inline = ["echo 'Wait until ssh is ready'"]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(pathexpand(var.private_key_path))
      host = aws_instance.doczilla_proxy.private_ip
    }
}

provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-primary} --instance-ids ${aws_instance.doczilla_proxy.id} \
&& ansible-playbook -i ${aws_instance.doczilla_proxy.private_ip}, ansible_templates/doczilla_proxy.yml
EOF
  }
}

resource "aws_eip" "doczilla_proxy_eip" {
  instance = aws_instance.doczilla_proxy.id
  vpc = true
}
