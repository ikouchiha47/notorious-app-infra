# notorious-app-infra

Infra code to deploy application to prod.


### Requirements:

- `AWS` account
- `S3` bucket named `notorious-tfstates`
- `ECR` repostiory, to fetch the docker image from
- `terraform`


### Structure

**awsecsdeploy**

This has code to setup the `iam roles` and `networking interface`. 

Pre-requisites:
- get your AWS_ACCOUNT_ID from [AWS](https://us-east-1.console.aws.amazon.com/billing/home?region=us-east-1#/account), alternatively you can use the `sdk`

```shell
aws sts \
      get-caller-identity \
      --query "Account" \
      --output text \
      --profile="$AWS_PROFILE"
```

- Each directory inside `awsdeploy/` has a submodule, Each uses the `.env` file, to export required `TF_VAR_*`, which are used as `variable` in tf.\
A custom script `terrawrap` takes care of exporting the `TF_VAR_*` before running the `terraform` commands.


To setup the `IAM` roles:

```shell
cd awsdeploy/iam
AWS_ACCOUNT=$AWS_ACCOUNT make terraform.plan
AWS_ACCOUNT=$AWS_ACCOUNT make terraform.apply
```

To setup the `vpc, security group, route53 zones`:

```shell
cd awsdeploy/networking
AWS_ACCOUNT=$AWS_ACCOUNT make terraform.plan
AWS_ACCOUNT=$AWS_ACCOUNT make terraform.apply
```



**servicedeploy**

This has the code for deploying the `rails` app from `ECR`. For the sake of simplicity, we have used `$APPNAME:latest`, to avoid\
storing the version number in ssm params.


Running it is same as others, the terraform root directory is inside `servicedeploy/service`.\
This can be made a bit better by incorportaing `terraform modules`, Each service then can have its own directory.



### Completing setup

After this and the `../aswdeploy/networking` is deployed successfully

- Go to your (Route53 Zone)[https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones?region=us-east-1#]
- Inside your hosted zone, get the 4 `NS Records`
- Go to your **domain name provider** like *godaddy*, *hostinger*, and update your `nameserver`, with the above values
