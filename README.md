# Terraform AWS GitLab Runner

Terraform code to spin up an AWS Auto Scale Group.

The runner will register upon starting and unregister when terminating.

An ASG policy has been configured to spin up extra instances when (CPU) utilization is high. (And to terminate instances when CPU utilization is low.)

## Variables

|variable                        |default             |
|--------------------------------|--------------------|
|gitlab_runner_concurrency       |2                   |
|gitlab_runner_registration_token|null                |
|gitlab_runner_url               |"https://gitlab.com"|

So the only variable required to be set is `gitlab_runner_registration_token`.

See `examples/default/main.tf` for sample code how to integrate.
