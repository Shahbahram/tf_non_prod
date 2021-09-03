#output "shah_admin_wks_private_ip" {
#value=aws_instance.shah_admin_wks.private_ip
#}
output "tomacat_app_server_private_ip" {
  value = aws_instance.tomcat_app_server.private_ip
}
output "proxy_server_1_private_ip" {
  value = aws_instance.proxy_server_1.private_ip
}
