#Launch Template
resource "aws_launch_template" "tf_asg_ec2_template" {
  name = "EC2_Launch_Template"
  image_id = "ami-08aa372c213609089"
  instance_type = "t2.micro"
  user_data = filebase64("script.sh")
  vpc_security_group_ids =[aws_security_group.tf_sg_ec2.id]
}

#ASG Creation with EC2 instance as target
resource "aws_autoscaling_group" "tf_asg_ec2" {
  name = "EC2_Auto_Scaling_Group"
  min_size = "1"
  max_size = "2"
  desired_capacity = "1"
  launch_template {
    id = aws_launch_template.tf_asg_ec2_template.id
  }
  depends_on = [ aws_launch_template.tf_asg_ec2_template ]
  vpc_zone_identifier = [ aws_subnet.tf_public_subnet.id,aws_subnet.tf_public_subnet_2.id ]
}

resource "aws_autoscaling_attachment" "tf_asg_ec2_attach" {
  autoscaling_group_name = aws_autoscaling_group.tf_asg_ec2.id
  lb_target_group_arn = aws_lb_target_group.tf_alb_targetgroup.arn
  depends_on = [ aws_autoscaling_group.tf_asg_ec2 ]
}

resource "aws_autoscaling_policy" "tf_asg_policy" {
  name = "TF_AutoScaling_Policy"
  autoscaling_group_name = aws_autoscaling_group.tf_asg_ec2.name
  adjustment_type = "ChangeInCapacity"
  policy_type = "StepScaling"
  step_adjustment {
    scaling_adjustment = "1"
    metric_interval_lower_bound = "1.0"
  }
}

#Cloudwatch Alarm configuration

resource "aws_cloudwatch_metric_alarm" "tf_cw_alarm" {
  alarm_name = "HIGH_CPU_Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods ="2"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.tf_asg_ec2.name
  }
  alarm_actions = [aws_autoscaling_policy.tf_asg_policy.arn]
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  threshold = "60"
  statistic = "Average"
  period = "60"
  }