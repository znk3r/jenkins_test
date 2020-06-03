# Pipeline testing example

## Terraform

Terraform requires 3 variables to run:

| Variable | Type | Dev value |
| --- | --- | --- |
| environment_name | string | my-env |
| environment_tag | string | dev |
| vpc_id | string | vpc-000000000000000 |
| private_subnet_id | string | subnet-000000000000000 |
| ssh_key_pair_name | string | dev-ssh-key-pair |

Then run:

```
terraform init
terraform apply
```

## Ansible

Ansible requires 1 variable `file_name`, which will be used as file name for a new file inside `/tmp`. This variable needs to be set in a `vars.yml` file as:

```
---
file_name: foo.txt
```

Then run:

```
ansible-playbook ansible/playbook.yml -i ansible/inventory.yml
```
