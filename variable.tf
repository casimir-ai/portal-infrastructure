variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.21"
  description = "Desired Kubernetes master version. If you do not specify a value, the latest available version is used"
}


variable "instance_type" {
  type        = string
  description = "Set of instance types associated with the EKS Node Group. Defaults to [\"t3.medium\"]. Terraform will only perform drift detection if a configuration value is provided"
}


variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "max_size" {
  type        = number
  description = "The maximum size of the AutoScaling Group"
}

variable "min_size" {
  type        = number
  description = "The minimum size of the AutoScaling Group"
}

variable "portal" {
  type = string
  description = "The name of the portal"
}

variable "tags" {
}

variable "health_check_type" {
}
variable "autoscaling_policies_enabled" {
}