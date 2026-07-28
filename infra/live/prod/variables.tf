variable "github_apply_principal_id" {
  description = "Object ID of the GitHub Actions apply service principal"
  type        = string
}

variable "github_plan_principal_id" {
  description = "Object ID of the GitHub Actions plan service principal"
  type        = string
}

variable "enable_restore_drill" {
  description = "Whether to create a restored copy of the marketplace database for DR drill"
  type        = bool
  default     = false
}

variable "restore_point_in_time" {
  description = "Point in time for Azure SQL restore drill in UTC RFC3339 format"
  type        = string
  default     = null
}