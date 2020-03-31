data "aws_availability_zones" "available" {}
 
### Create Security Group
 
resource "aws_security_group" "instance" {
  name = "${var.aws_instance_name}-sg"
  vpc_id = var.aws_vpc_id
 
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
  ami = var.aws_ami_id
  instance_type = var.turbonomic_instance_size
  key_name = var.aws_key_name
  associate_public_ip_address = true
  subnet_id = "${var.aws_launch_subnet}"
  vpc_security_group_ids = [ "${aws_security_group.instance.id}" ]
  tags = {
        Name = var.aws_instance_name
        ProvisionedBy = "Project Terra"
    }


  ### Run remote execution via SSH - Install Ansible

  provisioner "remote-exec" {
    inline = [
      "sudo yum install epel-release -y",
      "sudo yum install ansible -y",
    ]

    connection {
      type        = "ssh"
      user        = "centos"
      private_key = var.aws_ssh_key
      host        = self.public_ip
    }
  }
}
 
### Create Target Group
 
resource "aws_alb_target_group" "instance" {
    name = "${var.aws_instance_name}-target-group"
    port = 443
    protocol = "HTTPS"
    vpc_id = var.aws_vpc_id
}
 
### Create ALB
 
resource "aws_alb" "instance" {
    name = "${var.aws_instance_name}-elb"
    internal = false
    subnets = ["subnet-07d8310503d3d9704","subnet-091d4411443e82465"]
    security_groups = [ "${aws_security_group.instance.id}" ]

    tags = {
        Name = "${var.aws_instance_name}-lb"
    }
}
 
 
### Add instance to target group
 
resource "aws_lb_target_group_attachment" "instance" {
    target_group_arn = "${aws_alb_target_group.instance.arn}"
    target_id = "${aws_instance.cert-instance.id}"
    port = 443
}
 
### Add listener
 
resource "aws_alb_listener" "instance_443" {
    load_balancer_arn = "${aws_alb.instance.arn}"
    port = "443"
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "${var.aws_certificate_arn}"

    default_action {
        type = "forward"
        target_group_arn = "${aws_alb_target_group.instance.arn}"
    }
}
 
resource "aws_alb_listener" "instance_80" {
    load_balancer_arn      = "${aws_alb.instance.arn}"
    port                                         = "80"
    protocol                                  = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}
 
### Add DNS record
 
data "aws_route53_zone" "selected" {
            name = "turbonomiclabs.com."
}
 
resource "aws_route53_record" "cert33" {
            zone_id = "${data.aws_route53_zone.selected.zone_id}"
            name = var.aws_instance_name
            type = "A"       

    alias {
        name = "${aws_alb.instance.dns_name}"
        zone_id = "${aws_alb.instance.zone_id}"
        evaluate_target_health = false
    }
}