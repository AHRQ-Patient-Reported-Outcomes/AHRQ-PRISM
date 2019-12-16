#!/bin/bash

set -e
set -v

# Cleanup previous deploy
rm -rf ./.tmp/
mkdir .tmp

# Move files into ./.tmp
s3_bucket_name=`cat ../.s3_bucket_name`

cp -a ./config ./.tmp
cp -a ./lib ./.tmp
cp -a ./node_modules ./.tmp

cp ./app.js ./.tmp
cp ./lambda.js ./.tmp
cp ./package.json ./.tmp
cp ./package-lock.json ./.tmp

# Zip, calculate hash, rename
cd ./.tmp
zip -r ../dist/prism-auth.zip *
cd ..

md5_var="$(md5 ./dist/prism-auth.zip | cut -d"=" -f2 | xargs)"
mv ./dist/prism-auth.zip "./dist/prism-auth-$(echo $md5_var).zip"

aws s3 cp "./dist/prism-auth-$(echo $md5_var).zip" "s3://$(echo $s3_bucket_name)/prism-auth-$(echo $md5_var).zip"

rm -rf ./.tmp/

echo "Code has been zipped and uploaded to S3."
echo "S3 bucket: $(echo $s3_bucket_name)"
echo "auth_s3_key = \"prism-auth-$(echo $md5_var).zip\""
