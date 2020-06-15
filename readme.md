# Pipeline testing example

This is only a quick/dirty proof of concept to validate a provisioning workflow from Jenkins.

The goal is to be able to create, update and destroy full environments from Jenkins. These environments are created in AWS with Terraform, and configured with Ansible.

When a new environment is created, we stored the configuration used (`backend.tf` and `*.tfvars`) in parameter store, but any other storave system could be used as a replacement. When the environment is going to be updated, we retrieve and use those configuration. When the environment is destroyed, we delete the configuration files.

Part of the requirements is to be able to create multiple instances of the application on the same environment. For example, there are 5 developers, and each one creates their own dev environment in AWS, or a different UAT environment is created to validate each feature with the client/stake holder. This is more complex than just doing deployments in pre-defined and fixed environments like SIT, Staging or Production.

### Possible improvements

- Waiting for the EC2 instance to be up and ssh accessible can be improved. At the moment, is dependent on AWS instance checks and can take several minutes, but you can ssh into the instance a lot sooner. This check should be replaced with a ssh connectivity check instead, but to achieve that the instance needs better tagging.
- Input values for environment creation could be retrieved dynamically from a configuration file. The same configuration file could include validation checks for the input.
- Pipeline should fail if the retrieval from parameter store fails. At the moment, the pipeline continues even when we don't have the configuration file. This PoC needs better error handling.
- Another pipeline can be created to run validation checks on the new environment (Kitchen, InSpec, ServerSpec or similar). This pipeline would be called after each execution of the update pipeline.
- Calling the create pipeline for an existing environment should retrieve the configuration from parameter store, and load the values as defaults for the input parameters. This could provide an easy way to edit an existing environment.
- Evaluating use of vault instead of parameter store for secrets.

## Terraform

Terraform requires some variables to create the environment. Some of these variables are common for all the instances created in the same environment (like VPC, subnets and SSH keys)

| Variable | Dev value | Notes |
| --- | --- | --- |
| environment_name | my-env | Unique name for the environment you are provisioning. |
| owner | Name Surname - email@domain.com | Information about the environment owner. |
| team | Rocket Team | Name of the team supporting the environment. |
| environment_tag | dev | Environment type: dev, uat, sit, stg, prod. |
| vpc_id | vpc-000000000000000 | AWS VPC ID. This value is common for all environments of the same type. |
| private_subnet_id | subnet-000000000000000 | AWS subnet ID. This value is common for all environments of the same type. |
| ssh_key_pair_name | dev-ssh-key-pair | SSH key pair to use for the EC2 instance, ansible needs access to the private key to be able to SSH inside, so this keypair needs to be fixed for the environment and known by Jenkins |

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
