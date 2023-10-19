variable "bucket_name" {
  type    = string
  default = "tf-state-bucket"
}

variable "project_id" {
  type    = string
  default = "guru-com-vc"
}

variable "service_attachment" {
  type    = string
  default = "projects/ub9770edae24cf124p-tp/regions/southamerica-east1/serviceAttachments/apigee-southamerica-east1-6k48"
}


variable "ssl_certificates" {
  description = "A list of SSL certificates for the HTTPS LB."
  type        = list(string)
  default = [ "certificates" ]
}