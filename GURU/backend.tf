resource "google_storage_bucket" "backend" {
  name = "tf-state-bucket-guru"
  location = "US"
  force_destroy = true
}

terraform {
  backend "gcs" {
    bucket = "tf-state-bucket-guru"
    prefix = "terraform/state"
  }
}
