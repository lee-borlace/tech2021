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
variable "resource_group_name" {}
variable "environment_abbreviation" {}