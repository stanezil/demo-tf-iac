## Demo vulnerable infrastructure
This terraform will install
-    A small, publicly exposed, EC2 running un-patched Apache Tomcat 8.5 web server and 2.14.1 log4j with critical log4shell vulnerability
-    A small, publicly exposed, EC2 running un-patched MongoDB database with fake e-mail PII stored
-    A small, publicly exposed, RDS managed PostgreSql database with fake e-mail PII stored
-    A publicly exposed S3 bucket with fake e-mail PII stored 
-    A Highly privileged role that runs the infrastructure that can assume root
-    A keypair will be saved to the EC2 Apache web server home directory

## Requirements
-   AWSCLI
-   Terraform
-   Set VPC & subnet CIDRs, root account id, and region in vars.tf
-   AWS_ACCESS_KEY and AWS_SECRET_KEY (required by TF provider.  You will be prompted at plan/apply)
-   Python 3 Installed
-   Python MySQL Connector Installed: ```pip3 install mysql-connector-python```
-   Python Faker Installed: ```pip3 pip install Faker```

     Note: Faker is a utility to generate fake e-mail data for the databases and bucket

## Instructions
-   Setup requirements
-   terraform init
-   terraform plan (enter AWS key and secret)
-   terraform apply

     Note: applying Terraform should take 5 - 10 mins

-   terraform destroy (to remove)


## Credits 
- Special thanks for John Giancola as the original creator 