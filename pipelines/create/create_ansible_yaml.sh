#!/usr/bin/env bash

#
# General script to build Ansible configuration file from environment variables
#

echo "# File automatically generated from Jenkins on `date`"
echo "---"
echo "file_name: ${FILENAME}"
