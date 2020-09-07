TARGET=tutorial
VARS-FILE=pipeline-vars.yml

CREATE=create-cluster
DESTROY=destroy-cluster

.PHONY: login-concourse
login:
	@echo "Logging into target tutorial with fly"
	yes | fly -t $(TARGET) login -u test -p test -c http://localhost:8080

.PHONY: create-cluster
create-cluster:
	@echo "Pipeline to create resources on AWS via concourse"
	yes | fly -t $(TARGET) set-pipeline -c ci/pipeline.yml -p $(CREATE) -l $(VARS-FILE)
	yes | fly -t $(TARGET) unpause-pipeline -p $(CREATE)
	yes | fly -t $(TARGET) trigger-job -j $(CREATE)/$(CREATE)

.PHONY: destroy-cluster
destroy-cluster:
	@echo "Pipeline to destroy all resources via concourse"
	yes | fly -t $(TARGET) set-pipeline -c ci/pipeline.yml -p $(DESTROY) -l $(VARS-FILE)
	yes | fly -t $(TARGET) unpause-pipeline -p $(DESTROY)
	yes | fly -t $(TARGET) trigger-job -j $(DESTROY)/$(DESTROY)