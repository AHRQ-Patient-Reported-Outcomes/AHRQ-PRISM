#!/bin/bash

set -e

# Move files into ./.tmp

s3_bucket_name=`cat ../.s3_bucket_name`

# Create the .tmp folder if it does not exist
mkdir -p ./.tmp

cp -a ./.bundle ./.tmp
cp -a ./app ./.tmp
cp -a ./config ./.tmp
cp -a ./lib ./.tmp

cp .ruby-version ./.tmp
cp .ruby-gemset ./.tmp
cp ./boot.rb ./.tmp
cp ./config.ru ./.tmp
cp ./Gemfile ./.tmp
cp ./Gemfile.lock ./.tmp
cp ./lambda.rb ./.tmp
cp ./Rakefile ./.tmp

# Zip, calculate hash, rename
# We cd into the folder so that we get all files and folders on the top level
cd ./.tmp
bundle install --no-deployment --without development test

# Run using docker image so that native extensions compile properly
docker run -v `pwd`:`pwd` -w `pwd` -i -t lambci/lambda:build-ruby2.5 bundle install --no-deployment --without development test
docker run -v `pwd`:`pwd` -w `pwd` -i -t lambci/lambda:build-ruby2.5 bundle install --deployment --without development test

zip -r ../dist/prism_api.zip *
cd ..
md5_var="$(md5 ./dist/prism_api.zip | cut -d"=" -f2 | xargs)"
mv ./dist/prism_api.zip "./dist/prism_api-$(echo $md5_var).zip"

aws s3 cp "./dist/prism_api-$(echo $md5_var).zip" "s3://$(echo $s3_bucket_name)/prism_api-$(echo $md5_var).zip"

echo "Code has been zipped and uploaded to S3."
echo "S3 bucket: $(echo $s3_bucket_name)"
echo "Code Key: prism_api-$(echo $md5_var).zip"

echo "api_s3_key = \"prism_api-$(echo $md5_var).zip\""
