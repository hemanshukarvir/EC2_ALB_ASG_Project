resource "aws_instance" "custom_vpc_ec2instance" {
  ami = "ami-08aa372c213609089"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.tf_public_subnet.id
  vpc_security_group_ids = [aws_security_group.tf_sg_ec2.id]
  associate_public_ip_address = "true"
  user_data = file("script.sh")
  key_name = "terraform_ec2_pem"
}

#ALB creation with EC2 instance as target

resource "aws_lb" "tf_alb" {
  name = "tf-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.tf_sg_alb.id]
  subnets = [aws_subnet.tf_public_subnet.id,aws_subnet.tf_public_subnet_2.id]

  access_logs {
    bucket = "tf-alb-logs-bucket-hkarvir"
    enabled = false
  }
}

output "tf_alb_dns" {
  value = aws_lb.tf_alb.dns_name
}

#Target Group for ALB towards EC2

resource "aws_lb_target_group" "tf_alb_targetgroup" {
  target_type = "instance"
  vpc_id = aws_vpc.tf_vpc.id
  port = "80"
  protocol = "HTTP"
  health_check {
    enabled = true
    interval = "25"
    port = "80"
    protocol = "HTTP"
    healthy_threshold = "5"
  }
}

resource "aws_lb_target_group_attachment" "tf_alb_targetgroup_attach" {
  target_group_arn = aws_lb_target_group.tf_alb_targetgroup.arn
  target_id = aws_instance.custom_vpc_ec2instance.id
  depends_on = [ aws_lb_target_group.tf_alb_targetgroup ]
}

resource "aws_lb_listener" "tf_alb_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tf_alb_targetgroup.arn
  } 
  depends_on = [ aws_lb_target_group.tf_alb_targetgroup ]
}