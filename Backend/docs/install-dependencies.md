# Install PRISM Backend Dependencies
There are a number of libraries and accounts that need to be setup and installed before we can proceed.
1. Have an active AWS account and a [named AWS profile installed](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) on your local machine
2. Install the [AWS CLI.](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html). Ensure that `aws sts get-caller-identity` returns your userId and account information properly.
3. [Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html).
4. [Install Docker](https://docs.docker.com/v17.12/install/)
5. Install Ruby 2.5.7 & bundler
6. Install Node 11.11 (LTS) and NPM
