module "module_name_1" {
  source = "./modules/resource-group"

}

module "module_name_2" {
  source = "./modules/aks-cluster"

}

module "module_name_3" {
  source = "./modules/vnet"
  
}