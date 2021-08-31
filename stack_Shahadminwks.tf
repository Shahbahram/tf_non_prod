#Create and bootstrap EC2 in us-west-2
resource "aws_instance" "shah_admin_wks" {
  provider             = aws.region-primary
  ami                  = "ami-02d40d11bb3aaf3e5"
  instance_type        = var.instance-type
  iam_instance_profile = "Wdtvs_Terraform_Role"
  #  key_name                    = aws_key_pair.linux-np-tomcat.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.SSH_Access_From_VPC_Clients.id]
  subnet_id                   = aws_subnet.DWUW2NPPVSN-Private-Zone.id

  tags = {
    Name = "shah_admin_wks"
  }
  depends_on = [aws_route_table.DWUW2NPPVRT-NP-Private-RT]
}
