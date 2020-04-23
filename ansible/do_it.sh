#!/usr/bin/env bash
ansible-playbook \
  -i aws_ec2.yml \
  -u ec2-user \
  --extra-vars "version=master-bd65454b env=prod" \
  deploy.yml
