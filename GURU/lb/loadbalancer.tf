
resource "google_compute_global_address" "default" {
  project      = var.project_id
  name         = "loadbalancer-address"
  ip_version   = "IPV4"
  address_type = "EXTERNAL"
}


resource "google_compute_global_forwarding_rule" "forwarding_rule_prd" {
  provider              = google-beta
  project               = var.project_id
  name                  = "frontend-lb-pr"
  target                = google_compute_target_https_proxy.default.self_link
  ip_address            = google_compute_global_address.default.address
  port_range            = "443"
  depends_on            = [google_compute_global_address.default]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  # labels                = var.custom_labels
}


resource "google_compute_target_https_proxy" "default" {
  project = var.project_id
  name    = "loadbalancer-https-proxy"
  url_map = google_compute_url_map.url_map.name

  ssl_certificates = var.ssl_certificates
}


resource "google_compute_managed_ssl_certificate" "google_certs" {
  project = var.project_id
  name    = "certificates"
  managed {
    domains = ["guru-prd-apigee.guruapi.com", "guru-qa-apigee.guruapi.com", ]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_network_endpoint_group" "psc_neg" {
  project               = var.project_id
  name                  = "psc-neg-southamerica-east1-apigee"
  region                = "southamerica-east1"
  network               = "guru-gcp-prd"
  subnetwork            = "projects/guru-com-vc/regions/southamerica-east1/subnetworks/guru-private-sa-prd" //   esperar resposta fabio
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = var.service_attachment
  lifecycle {
    create_before_destroy = true
  }
}




resource "google_compute_backend_service" "psc_backend" {
  project               = var.project_id
  name                  = "apigee-loadbalancer-externo-backend"
  port_name             = "https"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
 # security_policy       = "allow-and-deny-ips"
  backend {
    group = google_compute_region_network_endpoint_group.psc_neg.self_link
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = "lb-apigee"
  default_service = google_compute_backend_service.psc_backend.id
}


