output "instance_public_ip" {

  value = aws_instance.web_server.public_ip
}

output "instance_id" {

  value = aws_instance.web_server.id
}

output "latest_ami_used" {

  value = data.aws_ami.amazon_linux.id
}