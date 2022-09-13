##Outputs, are like "return" value of a module. Let's you expose/export resources attributes to parent module.
output "bt_app-subnet_output" {
    value = aws_subnet.bt_app-subnet_1
}