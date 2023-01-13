variable "gitlab_runner_concurrency" {
  default     = 2
  description = "The amount of jobs to run in parallel."
  type        = number
  validation {
    condition     = var.gitlab_runner_concurrency > 0
    error_message = "Please use a positive integer."
  }
}

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

variable "gitlab_runner_extra_disk_iops" {
  default     = 1600
  description = "The number of iops for the extra disk."
  type        = number
  validation {
    condition     = var.gitlab_runner_extra_disk_iops > 400
    error_message = "Please specify an amout of iops of 400 or more."
  }
}
