# Azure Provider
terraform {
required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "version"
        }
    }
}

# AWS Provider
terraform {
required_providers {
    azurerm = {
        source  = "hashicorp/aws"
        version = "version"
        }
    }
}

# GCP Provider
terraform {
required_providers {
    azurerm = {
        source  = "hashicorp/google"
        version = "version"
        }
    }
}