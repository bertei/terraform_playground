## Security Group 
resource "aws_security_group" "bt_app-sg_1" {
    name = "bt_app-sg_1"
    vpc_id = var.vpc_id

    ##Incoming traffic rules
    ##ssh into ec2
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ##access from browser
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ##Exiting/outgoing traffic rules
    ##installations, fetch dependencies
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1" ##-1 to not restrict any protocol
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = [] ##for allowing access to vpc endpoints
    }

    tags = {
        Name: "${var.env_prefix}-sg_1"
    }
}

## Data source (in this case works to retrieve a dynamic variable)
data "aws_ami" "latest_amazon_linux_image" {
    most_recent = true ##retrieves most recent image
    owners = ["amazon"] ##ami owner
    ##lets you define the criteria for this query. Example: Amazon gimme the most recent image that have the name that starts with...
    filter {
        name = "name"
        values = [var.image_name]
    }
}
## EC2
resource "aws_instance" "bt_app-webserver_1" {
    ##Mandatory
    ami = data.aws_ami.latest_amazon_linux_image.id
    instance_type = var.instance_type
    ##Optional (if not specified, aws will grant default options)
    subnet_id = var.subnet_id
    vpc_security_group_ids = [aws_security_group.bt_app-sg_1.id]
    availability_zone = var.avail_zone
    ##Public IP for the ec2
    associate_public_ip_address = true
    ##bootstrap
    user_data = file("./entry-script.sh")
    ##Key
    key_name = var.key
    ##Tags
    tags = {
        Name: "${var.env_prefix}-webserver_1"
    }
    ##
    metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    }
}