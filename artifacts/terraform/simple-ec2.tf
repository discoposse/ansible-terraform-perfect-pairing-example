data "aws_availability_zones" "available" {}
 
### Create Security Group
 
resource "aws_security_group" "instance" {
  name = "cert-${var.aws_instance_name}-sg"
  vpc_id = "${var.aws_vpc_id}"
 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Create EC2 Instance from AMI
 
resource "aws_instance" "cert-instance" {
  ami = "ami-08aaa44ddb42288f1"
  instance_type = "t2.large"
  key_name = "${var.aws_key_name}"
  subnet_id = "${var.aws_launch_subnet}"
  associate_public_ip_address = true
  vpc_security_group_ids = [ "${aws_security_group.instance.id}" ]
  tags = {
        Name = "${var.aws_instance_name}"
        ProvisionedBy = "Project Terra"
    }

  provisioner "remote-exec" {
    inline = [
      "yum install epel-release -y",
      "yum install ansible -y",
    ]

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = aws_ssh_key
      host        = "${aws_instance.cert-instance.*.public_ip}"
    }
  }
}