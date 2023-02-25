locals {
  size_cpu_map = {
    small  = 2
    medium = 4
    large  = 8
  }
  cpu = local.size_cpu_map[var.gitlab_runner_size]

  size_memory_map = {
    small  = 1024
    medium = 2048
    large  = 4096
  }
  memory = local.size_memory_map[var.gitlab_runner_size]

  size_iops_map = {
    small  = 1600
    medium = 3200
    large  = 6400
  }
  iops = local.size_iops_map[var.gitlab_runner_size]

  size_concurrency_map = {
    small  = 4
    medium = 8
    large  = 16
  }
  concurrency = local.size_concurrency_map[var.gitlab_runner_size]

  size_spot_max_price_map = {
    small  = 0.4
    medium = 0.8
    large  = 1.6
  }
  max_price = local.size_spot_max_price_map[var.gitlab_runner_size]
}
