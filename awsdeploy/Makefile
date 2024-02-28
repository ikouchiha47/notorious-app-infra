VPC_NAME ?= NotoriousVPC
DOMAIN_NAME ?= mr-notorious.shop
APP_NAME ?= notorious

setup.mac:
	brew tap hashicorp/tap
	brew install hashicorp/tap/terraform

terraform.ecs.plan: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} APP_NAME=notorious DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash scripts/tcl.sh -a plan )

terraform.ecs.import: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} APP_NAME=notorious DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash scripts/tcl.sh -a import )

terraform.ecs.apply: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash scripts/tcl.sh -a apply )
	chmod 400 tf-key-pair.pem

terraform.ecs.destroy: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash scripts/tcl.sh -a destroy )

terraform.ecs.show: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash scripts/tcl.sh -a show )

terraform.svc.plan: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} APP_NAME=notorious DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash ./scripts/tcl.sh -a plan_svc )

terraform.svc.apply: 
	( AWS_ACCOUNT=${AWS_ACCOUNT} AWS_PROFILE=${AWS_PROFILE} APP_NAME=notorious DOMAIN_NAME=${DOMAIN_NAME} VPC_NAME=${VPC_NAME} bash ./scripts/tcl.sh -a plan_svc )

sync.origin:
	git push origin main:master
	git push gitlab main:master
