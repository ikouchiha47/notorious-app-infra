TF_PLAN_FILE ?= tfplan.plan

terraform.plan:
	( ../scripts/terrawarp init -backend-config=./infra.hcl -reconfigure && \
		../scripts/terrawarp validate && \
		../scripts/terrawarp plan -out=$(TF_PLAN_FILE))

terraform.apply:
	( ../scripts/terrawarp apply $(TF_PLAN_FILE) )

terraform.destroy:
	( ../scripts/terrawarp init -backend-config=./infra.hcl -reconfigure && \
		../scripts/terrawarp destroy )

