variable "gitlab_runner_registration_token" {
  description = "The registration token for the GitLab runner."
  type        = string
  validation {
    condition     = length(var.gitlab_runner_registration_token) >= 8
    error_message = "Please use a valid registration token of 8 or more characters."
  }
}

variable "gitlab_runner_url" {
  default     = "https://gitlab.com"
  description = "The URL to the GitLab instance to register the GitLab runner to."
  type        = string
  validation {
    condition     = can(regex("^http(s?)://.*", var.gitlab_runner_url))
    error_message = "Please specify a URL starting with \"http://\" or \"https://\"."
  }
}

variable "gitlab_runner_extra_disk_size" {
  default     = 64
  description = "The size in GB of the disk to attach."
  type        = number
  validation {
    condition     = var.gitlab_runner_extra_disk_size > 8
    error_message = "Please specify a disksize of 8 (GB) or more."
  }
}

variable "gitlab_runner_cooldown_time" {
  default     = 1800
  description = "The amount of time in seconds after which the runner will be stopped and removed."
  type        = number
  validation {
    condition     = var.gitlab_runner_cooldown_time > 180
    error_message = "Please specify a minimum of 180 seconds."
  }
}

variable "gitlab_runner_size" {
  default     = "small"
  description = "The size of the GitLab runner to start. This variable influences CPU, memory and job concurency."
  type        = string
  validation {
    condition     = contains(["small", "medium", "large"], var.gitlab_runner_size)
    error_message = "Please select on of \"small\", \"medium\" or \"large\".s"
  }
}
