variable "api" {
  type        = string
  description = "The URL of the Kubernetes API"
  sensitive   = true
}

variable "token" {
  type        = string
  description = "The kubeadm join token"
  sensitive   = true
}

variable "ca_cert_hash" {
  type        = string
  description = "The hash of the CA certificate"
}

variable "node_count" {
  type        = number
  description = "The number of nodes to create"
  default     = 1
}

variable "os_image" {
  type        = string
  description = "Channel for a Container Linux derivative (stable, beta, alpha)"
  default     = "stable"

  validation {
    condition     = contains(["stable", "beta", "alpha"], var.os_image)
    error_message = "The os_image must be stable, beta, or alpha."
  }
}

variable "cluster_name" {
  type        = string
  description = "Cluster name used as prefix for the nodes names"
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH public keys for user 'core' and to register on Hetzner Cloud"
}

variable "server_type" {
  type        = string
  default     = "cx11"
  description = "The server type to rent"
}

variable "datacenter" {
  type        = string
  description = "The region to deploy in"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet in which to create the workers"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version to install"
}

variable "release_version" {
  type        = string
  default     = "v0.4.0"
  description = "The version of the Kubernetes release package"
}
