# Solution-wide
variable "org_name" {
    default = "lee"
}

variable "solution_name" {
    default = "rwa" 
}

variable "location" {
    default = "australiaeast"
}

variable "location_abbreviation" {
    default = "syd"
}

# Environment-specific
variable "TERRA_RESOURCE_GROUP_NAME" {}
variable "TERRA_ENVIRONMENT_ABBREVIATION" {}



