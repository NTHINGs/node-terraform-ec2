
provider "aws" {
  region = "us-east-1"
}

#############################################################
# VPC, subnet, security group and AMI
#############################################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  
  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2"
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

resource "aws_security_group" "allow_web" {
  name = "allow_http"
  description = "Allow http and ssh"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name = "example_key"
  public_key = "${file("keys/public")}"
}

resource "aws_instance" "ec2" {
  ami = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"
  subnet_id = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids = ["${aws_security_group.allow_web.id}"]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.auth.key_name}"
  tags = "${map("Name", "nodejs-example")}"

  provisioner "file" {
    source = "./app"
    destination = "/home/ec2-user/app"
    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("keys/private")}"
    }
  }

  provisioner "remote-exec" {
    script = "./node.sh"

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = "${file("keys/private")}"
    }
  }
}

output "public_dns" {
  value = "${aws_instance.ec2.public_dns}"
}

output "public_ip" {
  value = "${aws_instance.ec2.public_ip}"
}

