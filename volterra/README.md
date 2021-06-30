# Instructions to deploy this template

Step1: Input terraform tfvars file content
```
api_p12_file = "<Your p12 file path>"
location = "westus2"
name = "nebula"
azure_client_id = "<your azure client id>"
azure_subscription_id = "<your azure subscription id>"
azure_tenant_id = "<your azure tenant id>"
resource_group_name = "nebula"
volterra_tf_action = "apply"
url = "https://<tenant-name>.console.ves.volterra.io/api"
```

Step2: Export secrets through env variables
```bash
export TF_VAR_azure_client_secret=<Your azure client secret>
export VES_P12_PASSWORD=<your volterra api p12 file password>
```

Step3: Run terraform init, plan and apply
```bash
terraform init
terraform plan
terraform apply
```
