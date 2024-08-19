variable "aws_region" {
  description = "The AWS region to deploy into"
  type        = string
  default     = "us-east-1" # You can override this via environment variables
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = "" # Leave empty if you are using environment variables
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = "" # Leave empty if you are using environment variables
}
