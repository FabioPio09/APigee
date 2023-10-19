data "google_client_config" "current" {}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  network                 = "guru-gcp-prd"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["guru-prd-apigee-1","guru-prd-apigee-2"]
}

resource "google_kms_key_ring" "apigee_keyring" {
  name     = "apigee-keyring-x"
  location = "southamerica-east1"
}

resource "google_kms_crypto_key" "apigee_key" {
  name            = "apigee-key"
  key_ring        = google_kms_key_ring.apigee_keyring.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = "guru-com-vc"
  service  = "apigee.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "apigee_sa_keyuser" {
  crypto_key_id = google_kms_crypto_key.apigee_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_project_service_identity.apigee_sa.email}",
  ]
}

resource "google_apigee_organization" "apigee_org" {
  analytics_region                     = "us-east1"
  display_name                         = "apigee-org"
  description                          = "Terraform-provisioned Apigee Org."
  project_id                           = "guru-com-vc"
  authorized_network                   = "guru-gcp-prd"
  runtime_database_encryption_key_name = google_kms_crypto_key.apigee_key.id
  billing_type                         = "PAYG"
 

  depends_on = [
    google_service_networking_connection.apigee_vpc_connection,
    google_kms_crypto_key_iam_binding.apigee_sa_keyuser,
  ]
}

resource "google_apigee_instance" "apigee_instance" {
  consumer_accept_list     = [
    "prj-apigee",
  ]
  name                     = "southamerica-east1"
  location                 = "southamerica-east1"
  org_id                   = google_apigee_organization.apigee_org.id
  ip_range                 = "10.200.208.0/22"
  peering_cidr_range       = "SLASH_22"
  disk_encryption_key_name = google_kms_crypto_key.apigee_key.id
}
##############################

resource "google_apigee_envgroup" "apigee_envgroup" {
  org_id    = google_apigee_organization.apigee_org.id
  name      = "grp-apigee-prod"
  hostnames = ["guru-prd-apigee.guruapi.com"] 
}

resource "google_apigee_environment" "apigee_env" {
  org_id       = google_apigee_organization.apigee_org.id
  name         = "prod"
  description  = "Apigee Environment Prod"
  display_name = "prod"
}

resource "google_apigee_envgroup_attachment" "env_attachment" {
  envgroup_id  = google_apigee_envgroup.apigee_envgroup.id
  environment  = google_apigee_environment.apigee_env.name
}


resource "google_apigee_instance_attachment" "instance_attachment" {
  instance_id  = google_apigee_instance.apigee_instance.id
  environment  = google_apigee_environment.apigee_env.name
}
##############################################################

resource "google_apigee_envgroup" "apigee_envgroup_qa" {
  org_id    = google_apigee_organization.apigee_org.id
  name      = "grp-apigee-qa"
  hostnames = ["guru-qa-apigee.guruapi.com"]
}

resource "google_apigee_environment" "apigee_env_qa" {
  org_id       = google_apigee_organization.apigee_org.id
  name         = "qa"
  description  = "Apigee Environment qa"
  display_name = "qa"
}

resource "google_apigee_envgroup_attachment" "env_attachment_qa" {
  envgroup_id  = google_apigee_envgroup.apigee_envgroup_qa.id
  environment  = google_apigee_environment.apigee_env_qa.name
}

resource "google_apigee_instance_attachment" "instance_attachment_qa" {
  instance_id  = google_apigee_instance.apigee_instance.id
  environment  = google_apigee_environment.apigee_env_qa.name
}
###################################

