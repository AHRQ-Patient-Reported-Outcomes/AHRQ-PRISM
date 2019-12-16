#!/bin/bash

set -e

if [ `dirname $0` != "." ]
then
  echo 'Not root of folder. Please re-run from PrismAPI root'
  exit 1
fi

function deployApi() {
  echo 'Starting to deploy Ruby API ...'
  echo 'This may take a while, and will not update until done...'
  cd api
  output="`./zip-and-upload.sh | tail -n -1`"

  echo 'Finished Deploying Ruby API'
  echo "The S3 API Key is:"
  echo $output
  cd ..
  sed -i '' -E "s/^api_s3_key = \"prism_api-[a-zA-Z0-9]{32}\.zip\"$/`echo $output`/" ./terraform/secrets.auto.tfvars
  echo 'Updated terraform file'
}

function deployAuth() {
  echo 'Starting to deploy Auth API ...'
  echo 'This may take a while, and will not update until done...'

  cd auth
  output="`./zip-and-upload.sh | tail -n -1`"

  echo 'Finished Deploying Auth API'
  echo "The S3 API Key is:"
  echo $output

  cd ..
  sed -i '' -E "s/^auth_s3_key = \"prism-auth-[a-zA-Z0-9]{32}\.zip\"$/`echo $output`/" ./terraform/secrets.auto.tfvars
}

function deployBoth() {
  deployApi
  deployAuth
}

function deployTerraform() {
  cd terraform
  terraform apply -auto-approve
  cd ..
}

echo 'What directory would you like to deploy? Choices are: "api", "auth", "both", and "terraform"'

read deploy_command

if [ "$deploy_command" = "api" ]; then
  deployApi
  deployTerraform
elif [ "$deploy_command" = "auth" ]; then
  deployAuth
  deployTerraform
elif [ "$deploy_command" = "both" ]; then
  deployBoth
  deployTerraform
elif [ "$deploy_command" = "terraform" ]; then
  deployTerraform
  exit 0
fi
