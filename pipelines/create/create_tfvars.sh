#!/usr/bin/env bash

#
# General script to build Terraform tfvars file from environment variables
#

echo "# File automatically generated from Jenkins on `date`"
echo "environment_name = \"${ENV_NAME}\""
echo "environment_tag = \"${ENVIRONMENT}\""
echo "owner = \"${OWNER}\""
echo "team = \"${TEAM}\""
