
resource "google_compute_health_check" "health_check" {
  name               = "l7-ilb-basic-check"
  provider           = google-beta
  project            = var.project_id
  timeout_sec        = 1
  check_interval_sec = 1
  http_health_check {
    port = "80"
  }
}

resource "google_compute_region_backend_service" "backend-ilb" {
  project               = var.project_id
  name                  = "backend-ilb"
  region                = "southamerica-east1"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "INTERNAL_MANAGED"
  #health_checks         = [google_compute_health_check.health_check.id]

  backend {
    group           = google_compute_region_network_endpoint_group.psc_internal_neg.self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

}

resource "google_compute_region_url_map" "url_map_ilb" {
  project         = var.project_id
  region          = "southamerica-east1"
  name            = "lb-apigee-internal"
  default_service = google_compute_region_backend_service.backend-ilb.id
}


resource "google_compute_region_target_http_proxy" "proxy-ilb" {
  project = var.project_id
  region  = "southamerica-east1"
  name    = "proxy-http-apigee"
  url_map = google_compute_region_url_map.url_map_ilb.id
}


resource "google_compute_forwarding_rule" "fr-internal-apigee" {
  provider   = google-beta
  project    = var.project_id
  name       = "frontend-ilb-pr"
  region     = "southamerica-east1"
  network    = "guru-gcp-prd"
  subnetwork = "projects/guru-com-vc/regions/southamerica-east1/subnetworks/guru-apigee-prd-2" // esperar resposta do fabio
  #subnetwork            = data.terraform_remote_state.remote_state.outputs.vpc_hub_id
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = true
  target                = google_compute_region_target_http_proxy.proxy-ilb.id
  port_range            = "80"
  ip_protocol           = "TCP"
}

resource "google_compute_region_network_endpoint_group" "psc_internal_neg" {
  project               = var.project_id
  name                  = "psc-neg-southamerica-east1-apigee-internal-lb"
  region                = "southamerica-east1"
  network               = "guru-gcp-prd"
  subnetwork            = "projects/guru-com-vc/regions/southamerica-east1/subnetworks/guru-apigee-prd-2" //esperar resposta do fabio
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = var.service_attachment
  lifecycle {
    create_before_destroy = true
  }
}


