data "terraform_remote_state" "zone" {
  backend = "local"

  config = {
    path = format("state/%s-state.tfstate", var.ZONE)
  }
}
