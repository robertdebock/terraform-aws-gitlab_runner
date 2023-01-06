# A scale policy to go up 1 instance.
resource "aws_autoscaling_policy" "up" {
  name                  = "gitlab_runner_up"
  scaling_adjustment    = 1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 180
  autoscaling_group_name = aws_autoscaling_group.default.name
}

# An alarm for CPU saturated ASG instances.
resource "aws_cloudwatch_metric_alarm" "up" {
  alarm_name          = "gitlab_runner_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.default.name
  }
    alarm_description = "This metric monitor EC2 instance CPU utilization"
    alarm_actions     = [ aws_autoscaling_policy.up.arn ]
}

# A scale policy to go down 1 instance.
resource "aws_autoscaling_policy" "down" {
  name                  = "gitlab_runner_down"
  scaling_adjustment    = -1
  adjustment_type       = "ChangeInCapacity"
  cooldown              = 180
  autoscaling_group_name = aws_autoscaling_group.default.name
}

# An alarm for CPU depleted ASG instances.
resource "aws_cloudwatch_metric_alarm" "down" {
  alarm_name          = "gitlab_runner_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "10"
  dimensions          = {
    AutoScalingGroupName = aws_autoscaling_group.default.name
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [ aws_autoscaling_policy.down.arn ]
}
