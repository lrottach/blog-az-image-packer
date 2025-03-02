gh_uai_name = "dco-d1-img-gh-actions-uai1"
github_organization_target = "lrottach"
github_repository = "blog-az-image-packer"
container_name = "tfstate"
storage_account_name = "dcod1ghactst1"
tf_state_rg_name = "rg-dco-d1-img-tfstate"
identity_rg_name = "rg-dco-d1-img-identity"
location = "eastus"
tags = {
  environment = "dev"
  owner = "lrottach"
  description = "Packer image management [Blog]"
}
