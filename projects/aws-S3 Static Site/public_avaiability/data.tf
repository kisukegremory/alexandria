data "terraform_remote_state" "bucket" {
  backend = "local"

  config = {
    path = "../bucket/bucket.tfstate"
  }
}