Required configuration:
1. Install terraform on you machine
2. Check file terraform.tfvars for configuration.
 The description of every variable can be found in file variable.tf

To set up a new portal:

1. Make sure, you have correct authorization keys to AWS:

   export AWS_ACCESS_KEY_ID=<set your access key>
   export AWS_SECRET_ACCESS_KEY=<set your secret key>

2. Initiate the terraform
    terraform init -input=false

3. Make sure, your syntax is correct
    terraform validate

You should see something like
    Success! The configuration is valid, but there were some validation warnings as shown above.

4. Enter plan-command to see what resources would be created
    terraform plan -input=false

5. Finally create all the resources for future template
    terraform apply -auto-approve -input=false