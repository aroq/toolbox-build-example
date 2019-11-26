export TOOLBOX_PROJECT ?= toolbox
export TOOLBOX_DIR ?= .toolbox

export TOOLBOX_CORE_DIR ?= $(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/deps/toolbox

export TOOLBOX_DOCKER_IMAGE_VERSION ?= $(shell if [ -f $(TOOLBOX_CORE_DIR)/VERSION ]; then cat $(TOOLBOX_CORE_DIR)/VERSION; else echo 'latest'; fi)

export _TOOLBOX_CORE_TOOLS_TOOLBOX_IMAGE ?= aroq/toolbox:$(TOOLBOX_DOCKER_IMAGE_VERSION)
export _TOOLBOX_CORE_TOOLS_INITIALIZE_IMAGE ?= aroq/toolbox:$(TOOLBOX_DOCKER_IMAGE_VERSION)

export VARS_RETRIEVE_IMAGE ?= aroq/toolbox:$(TOOLBOX_DOCKER_IMAGE_VERSION)

export TOOLBOX_DOCKER_SSH_FORWARD ?= false

include $(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/deps/toolbox/makefile/include.mk
include $(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/deps/toolbox/makefile/variant.include.mk
include $(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/deps/toolbox/makefile/docker.include.mk

## Clean toolbox
.PHONY : toolbox/clean
toolbox/clean::
	@[ "$(TOOLBOX_PATH)" == '/' ] || \
	 [ "$(TOOLBOX_PATH)" == '.' ] || \
	   rm -fR $(TOOLBOX_PATH)

.PHONY : toolbox/build
toolbox/build: deps/install toolbox/cmd/create config/process

.PHONY : deps/install
deps/install:
	TOOLBOX_DOCKER_SSH_FORWARD="true" toolbox/bin/toolbox deps install

.PHONY : config/process
config/process:
	toolbox/bin/config process

.PHONY : toolbox/cmd/create
toolbox/cmd/create:
	toolbox/bin/toolbox cmd create

