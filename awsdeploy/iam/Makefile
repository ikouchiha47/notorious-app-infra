terraform.plan:
	( ../scripts/terrawarp init -backend-config=./infra.hcl -reconfigure && \
		../scripts/terrawarp validate && \
		../scripts/terrawarp plan -out=talon.plan)

terraform.apply:
	( ../scripts/terrawarp apply "talon.plan" )

terraform.destroy:
	( ../scripts/terrawarp init -backend-config=./infra.hcl -reconfigure && \
		../scripts/terrawarp destroy )