#Create and bootstrap EC2 in us-west-2
resource "aws_instance" "tomcat_app_server_1" {
  provider                    = aws.region-primary
  ami                         = "ami-0bcadaece3162039d"
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.linux-np.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.SSH_Access_From_VPC_Clients.id]
  subnet_id                   = aws_subnet.DWUW2NPPVSN-Private-Zone.id

  tags = {
    Name = "tomcat_app_server_1"
  }
  depends_on = [aws_ebs_volume.apps_vol01_1]
}

resource "aws_ebs_volume" "apps_vol01_1" {
  availability_zone = "us-west-2a"
  encrypted         = true
  size              = 100
}

resource "aws_volume_attachment" "tomact-app01-vol01_1" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.apps_vol01_1.id
  instance_id = aws_instance.tomcat_app_server_1.id

provisioner "remote-exec" {
    inline = ["echo 'Wait until ssh is ready'"]
    connection {
      type = "ssh"
      user = var.ssh_user
      private_key = file(pathexpand(var.private_key_path))
      host = aws_instance.tomcat_app_server_1.private_ip
    }
}

  provisioner "local-exec" {
    command = <<EOF
aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-primary} --instance-ids ${aws_instance.tomcat_app_server_1.id} \
&& ansible-playbook -i ${aws_instance.tomcat_app_server_1.private_ip}, ansible_templates/tm.yaml
EOF
  }

}

