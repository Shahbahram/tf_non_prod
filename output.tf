#output "shah_admin_wks_private_ip" {
#value=aws_instance.shah_admin_wks.private_ip
#}
output "doczilla_app_private_ip" {
  value = aws_instance.doczilla_app.private_ip
}
output "doczilla_proxy_private_ip" {
  value = aws_instance.doczilla_proxy.private_ip
}
