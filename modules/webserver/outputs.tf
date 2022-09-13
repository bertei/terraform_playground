output "aws_ami_id" {
    value = data.aws_ami.latest_amazon_linux_image.id
}

output "ec2_public_ip" {
    value = aws_instance.bt_app-webserver_1.public_ip
}