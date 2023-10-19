data "google_compute_network" "vpc-guru" {
  name = "guru-gcp-prd"
}


resource "google_compute_subnetwork" "sn-public-sec" {
  name          = "guru-apigee-prd-2"
  ip_cidr_range = "10.210.108.0/24"
  region        = "southamerica-east1"
  network       = data.google_compute_network.vpc-guru.self_link
  project       = "guru-com-vc"
  
  

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling = 0.5
    metadata = "INCLUDE_ALL_METADATA"
    metadata_fields = []
  }
}
