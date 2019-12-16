# How to deploy the PRISM Backend to AWS
The PRISM Backend consists of a number of AWS services and 2 lambda functions. The primary lambda function is written in ruby and functions as the primary API for the frontend. This is found in the `./api` folder. The other lambda function is call the Auth Lambda and servers to facilitate the OAuth/SMART on FHIR handshake between the PRISM app, the Identity Server and AWS Cognito. It is found in `./auth`. 

There are 2 primary steps to get a working PRISM backend up and running in AWS
1. [Configure AWS for deployment](#configure-aws-for-first-deployment)
2. [Deploy](#deploy)

__Prerequisites:__

There are a couple items you need to have before you can deploy
1. A FHIR Server that supports Patient and QuestionnaireResponse resources
2. A SMART on FHIR identity provider that supports OpenID connect
3. A client and it's ID registered with the SMART on FHIR server
4. Username and Password for an External Assessment Center (EAC) that supports FHIR next-q SDC
5. Ensure you have followed the `#install-dependencies.md` page to install all PRISM dependencies

## Configure AWS & Terraform for first deployment
Now that you have your accounts and libraries installed and ready, there are a few items that have to be manually setup and configured before we can deploy.
1. Create an S3 bucket to host the lambda code in. `aws s3api create-bucket --bucket my-bucket-name --region us-east-1`
2. Take the name of the bucket created in step 1 and write it in `./.s3_bucket_name` and in `./terraform/main.tf => locals#lambda_code_bucket_name`
3. Using the AWS route53 console, register a domain name. Add it to `./terraform/main.tf => locals#root_domain`
4. Using the AWS IAM console, [create an openID connect Identity Provider.](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
    * Go to IAM Console https://console.aws.amazon.com/
    * Navigate to "Identity Providers"
    * Click "Create Provider"
    * Choose "OpenID Connect"
    * Enter URL of Smart on FHIR identity server as "Provider URL"
    * Enter UID of client that you have registered with the SMART on FHIR server as the "Audience"
5. Add the "Thumbprint" of the AWS Identity Provider to `./terraform/main.tf => locals#hub_public_key_fingerprint`
6. Add the UID of the SMART on FHIR client to `./terraform/main.tf => locals#hub_client_ids`
7. Create the terraform secrets file. `cp ./terraform/secrets.auto.tfvars.sample ./terraform/secrets.auto.tfvars`
8. Update secrets file with EAC username and password.
9. Update the Auth Lambda Configuration Files
    * In `/PrismAPI/auth/config/` use the sample file to create an environment configuration file. Name example: `prism-for-nyc.js`
    * Within your new Auth config file,
        * Set the root domain to equal the name of the domain you registered in route53. NOTE! This app was built with PRISM and FHIR server on same domain. If this does not apply to you, rename file accordingly
        * Set the `accountId`, `identityPoolId`, `clientId`, `clientSecret` according to your setup
    * Update `./auth/config/environment.js#6` with the name of your new config file.

## Deploy
At this point, you should have everything in place to deploy all of the AWS services to have the PRISM backend up and running. To deploy, from within the PrismAPI folder, run:

    $ ./terraform-deploy.sh
    $ both

This will:
1. Build and upload the Auth Lambda
2. Build and upload the Ruby Lambda
3. Update `secrets.auto.tfvars` with the name of the lambda code
4. Create all terraform resources.
