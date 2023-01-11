# Create a security group for the loadbalancer.
resource "aws_security_group" "public" {
  description = "Public - Traffic to GitLab Runner nodes"
  name_prefix = "gitlab-runner-public-"
  vpc_id      = aws_vpc.default.id
  lifecycle {
    create_before_destroy = true
  }
}

# Allow the GitLab runners to be accessed over SSH.
resource "aws_security_group_rule" "ssh" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH (:22/tcp)"
  from_port         = 22
  protocol          = "TCP"
  security_group_id = aws_security_group.public.id
  to_port           = 22
  type              = "ingress"
}

# Allow the GitLab runners to use the internet.
resource "aws_security_group_rule" "internet" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Internet"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.public.id
  to_port           = 0
  type              = "egress"
}
