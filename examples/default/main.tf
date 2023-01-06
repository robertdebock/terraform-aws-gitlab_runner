# Call the module
module "gitlab_runner" {
  source                           = "../../"
  gitlab_runner_concurrency        = 4
  gitlab_runner_registration_token = "GET_YOUR_OWN_TOKEN_PLEASE"
}
