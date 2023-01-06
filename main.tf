# Find amis for the Vault instances.
data "aws_ami" "default" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

# Create a launch template.
resource "aws_launch_template" "default" {
  image_id = data.aws_ami.default.id
  block_device_mappings {
    device_name           = "/dev/sda1"
    ebs {
      volume_size           = 256
      delete_on_termination = true
      volume_type           = "io1"
      iops                  = 3200
    }
  }
  instance_requirements {
    memory_mib {
      min = 1024
    }
    vcpu_count {
      min = 2
    }
    cpu_manufacturers    = ["intel"]
    instance_generations = ["current"]
  }
  key_name               = aws_key_pair.default.key_name
  name_prefix            = "gitlab-runner-"
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.public.id]
  }
  update_default_version = true
  user_data = base64encode(templatefile("${path.module}/scripts/gitlab-runner.sh.tpl",
    {
      gitlab_runner_url                = var.gitlab_runner_url
      gitlab_runner_registration_token = var.gitlab_runner_registration_token
      gitlab_runner_concurrency        = var.gitlab_runner_concurrency
  }))
  lifecycle {
    create_before_destroy = true
  }
}

# Create a placement group that spreads.
resource "aws_placement_group" "default" {
  name         = "gitlab-runner"
  spread_level = "rack"
  strategy     = "spread"
}

# Create an auto scaling group.
resource "aws_autoscaling_group" "default" {
  desired_capacity   = 1
  min_size           = 1
  max_size           = 8
  health_check_type  = "EC2"
  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.default.id
        version            = aws_launch_template.default.latest_version
      }
      override {
        instance_requirements {
          memory_mib {
            min = 1024
          }
          vcpu_count {
            min = 2
          }
        }
      }
    }
  }
  name            = "gitlab-runner"
  placement_group = aws_placement_group.default.id
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "gitlab-runner"
  }
  vpc_zone_identifier = aws_subnet.public[*].id
  instance_refresh {
    strategy = "Rolling"
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ desired_capacity ]
  }
  timeouts {
    delete = "15m"
  }
}

# Let instance wait a bit before removing. This allows gitlab-runner to unregister.
resource "aws_autoscaling_lifecycle_hook" "default" {
  name                   = "gitlab_runner_unregister"
  autoscaling_group_name = aws_autoscaling_group.default.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 90
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}
