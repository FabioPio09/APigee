resource "google_project_service" "cloud-kms" {
  project = var.project_id
  service = "cloudkms.googleapis.com"
}

resource "google_project_service" "api-apigee" {
  project = var.project_id
  service = "apigee.googleapis.com"
}

resource "google_project_service" "api-compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "api-service-network" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_project_service" "cloud-resourcemanager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "application-integration-api" {
  project = var.project_id
  service = "integrations.googleapis.com"
}
