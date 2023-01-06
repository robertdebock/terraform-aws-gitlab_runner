# Create an SSH private key
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public part of the SSH key to AWS.
resource "aws_key_pair" "default" {
  key_name   = "gitlab-runner"
  public_key = tls_private_key.default.public_key_openssh
}

# Save the private part of the SSH key locally.
resource "local_sensitive_file" "default" {
  filename        = "id_rsa.pem"
  file_permission = "400"
  content         = tls_private_key.default.private_key_pem
}
