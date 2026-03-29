#!/bin/bash

### DO NOT MODIFY ###
ROLE_NAME=$1
EXISTING_ROLE=$(aws iam get-role --role-name "$ROLE_NAME" 2>&1)

if [[ $? -eq 0 ]]; then
  echo "{\"result\": \"found\"}"
else
  echo "{\"result\": \"not_found\"}"
fi