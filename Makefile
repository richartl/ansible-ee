IMAGE_DEV ?= oxzacrmdps01.azurecr.io/ansible-ee:dev
IMAGE_TAG ?= oxzacrmdps01.azurecr.io/ansible-ee:1.0.0
ENGINE ?= docker

export DOCKER_DEFAULT_PLATFORM=linux/amd64

build-dev:
	ansible-builder build -t $(IMAGE_DEV) --container-runtime $(ENGINE) -vvv

build-dev-nc:
	ansible-builder build -t $(IMAGE_DEV) --container-runtime $(ENGINE) --no-cache -vvv

build-tag:
	ansible-builder build -t $(IMAGE_TAG) --container-runtime $(ENGINE)

smoke-dev:
	$(ENGINE) run --rm $(IMAGE_DEV) ansible --version
	$(ENGINE) run --rm $(IMAGE_DEV) ibmcloud --version
	$(ENGINE) run --rm $(IMAGE_DEV) oci --version
	$(ENGINE) run --rm $(IMAGE_DEV) az version || true

login-acr:
	az acr login -n oxzacrmdps01

push-dev:
	$(ENGINE) push $(IMAGE_DEV)

push-tag:
	$(ENGINE) push $(IMAGE_TAG)
