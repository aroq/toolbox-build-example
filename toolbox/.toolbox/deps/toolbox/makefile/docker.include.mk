MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

DOCKER_ENV_VARS ?=
DOCKER_ENV_FILE ?=
DOCKER_CMD ?=
DOCKER_RUN_WORKING_DIR ?= -w "$(shell pwd)"
DOCKER_RUN_DEFAULT_VOLUME ?= -v "$(shell pwd)":"$(shell pwd)"
DOCKER_RUN_CLEAN ?= --rm
DOCKER_RUN_TTY ?= -it
DOCKER_RUN_ARGS ?= $(DOCKER_RUN_CLEAN) $(DOCKER_RUN_TTY) $(DOCKER_RUN_DEFAULT_VOLUME) $(DOCKER_RUN_WORKING_DIR)
DOCKER_RUN_MOUNT_VOLUME ?=

ECHO_PREFIX ?= make

ifeq ($(TOOLBOX_DOCKER_SSH_FORWARD),true)
ifeq ($(DETECTED_OS),OSX)
    # For OSX ssh-agent forwarding into Docker container - https://github.com/nardeas/ssh-agent.
    DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS ?= --volumes-from=ssh-agent -e SSH_AUTH_SOCK=/.ssh-agent/socket
else
    DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS ?=
endif
endif

#######################################
# docker.run - Execute docker run command with parameters
#######################################
.PHONY: docker.run
docker.run:
ifeq ($(TOOLBOX_DOCKER_SSH_FORWARD),false)
	@:
else
	@$(MAKE) docker.init.forward
endif

ifeq ("$(TOOLBOX_DEBUG)",true)
ifeq ("$(DOCKER_CMD_TITLE)","")
	@:
else
	# $(call colorecho,"$(ECHO_PREFIX) ≫ $(DOCKER_CMD_TITLE)")
endif
else
	@VARIANT_LOG_LEVEL="debug"
endif

	$(eval DOCKER_RUN_ARGS += $(if $(DOCKER_ENV_FILE),--env-file=$(DOCKER_ENV_FILE),))
	$(eval DOCKER_RUN_ARGS += $(if $(DOCKER_ENV_FILE2),--env-file=$(DOCKER_ENV_FILE2),))
	$(eval DOCKER_RUN_ARGS += $(if $(DOCKER_ENV_VARS),$(DOCKER_ENV_VARS),))
	$(eval DOCKER_RUN_ARGS += $(if $(DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS),$(DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS),))

	$(eval ARG_IMAGE = $(shell echo "$(FIRST_ARG)_IMAGE" | tr '[:lower:]' '[:upper:]'))
	$(eval ARG_IMAGE = $(subst /,_,$(ARG_IMAGE)))
	$(eval ARG_IMAGE = $(subst .,_,$(ARG_IMAGE)))

	$(eval TOOLBOX_TOOL_DOCKER_IMAGE = $(if $(TOOLBOX_TOOL_DOCKER_IMAGE),$(TOOLBOX_TOOL_DOCKER_IMAGE),$(${ARG_IMAGE})))

ifeq ("$(TOOLBOX_DEBUG)",true)
	docker run $(strip $(DOCKER_RUN_ARGS) $(DOCKER_RUN_MOUNT_VOLUME)) $(TOOLBOX_TOOL_DOCKER_IMAGE) sh -c '$(DOCKER_CMD)'
else
	@docker run $(strip $(DOCKER_RUN_ARGS) $(DOCKER_RUN_MOUNT_VOLUME)) $(TOOLBOX_TOOL_DOCKER_IMAGE) sh -c '$(DOCKER_CMD)'
endif

#######################################
# docker.init.forward
#######################################
.PHONY: docker.init.forward
docker.init.forward:
ifeq ($(DETECTED_OS),OSX)
	$(MAKE) docker.osx.ssh.agent
endif

LOCAL_SSH_ID_RSA_KEY_PATH ?= ~/.ssh
LOCAL_SSH_ID_RSA_KEY_FILE ?= id_rsa

#######################################
# docker.osx.ssh.agent
#######################################
.PHONY: docker.osx.ssh.agent
docker.osx.ssh.agent:
	@docker ps --filter "name=ssh-agent" --format "{{.Names}}" | grep -q ssh-agent || (docker run --rm -d --name=ssh-agent nardeas/ssh-agent && docker run --rm --volumes-from=ssh-agent -v $(LOCAL_SSH_ID_RSA_KEY_PATH):/.ssh -it nardeas/ssh-agent ssh-add /root/.ssh/$(LOCAL_SSH_ID_RSA_KEY_FILE))
