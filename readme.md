# Pipeline testing example

## Terraform

Terraform requires 3 variables to run:

| Variable | Type | Dev value |
| --- | --- | --- |
| environment_tag | string | dev |
| private_subnet_id | string | subnet-09d9054bb5cd4e5db |
| ssh_key_pair_name | string | ansible-runner-nonprod |
| ssh_security_group_name | string | devnet-dev-ssh-destination |

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
