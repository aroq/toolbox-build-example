MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

ENVIRONMENT ?=
PROCESS_RUN_ARGS =

FIRST_ARG := $(firstword $(MAKECMDGOALS))
LAST_ARG := $(lastword $(MAKECMDGOALS))

# The main variant-in-docker execution rule.
# Add this rule only if the file exists in the same dir
# having the name of the first make (make FIRST_ARG) argument.
ifneq (,$(wildcard $(FIRST_ARG)))
# Process RUN_ARGS
ifeq ($(FIRST_ARG),$(firstword $(MAKECMDGOALS)))
  PROCESS_RUN_ARGS = yes
endif
ifdef PROCESS_RUN_ARGS
  # use the rest as arguments for the rule
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif


.PHONY: $(FIRST_ARG)_before
$(FIRST_ARG)_before::
	@

.PHONY: $(FIRST_ARG)
$(FIRST_ARG):: $(FIRST_ARG)_before $(FIRST_ARG)_main $(FIRST_ARG)_after
	@

.PHONY: $(FIRST_ARG)_after
$(FIRST_ARG)_after::
	@

ifneq ($(TOOLBOX_DOCKER_SKIP),true)

ifeq ($(TOOLBOX_RUN_VARIANT),true)
.PHONY: $(FIRST_ARG)_main
$(FIRST_ARG)_main::
	@$(MAKE) docker.run.variant.vars \
		DOCKER_CMD_TITLE="Execute './$(FIRST_ARG) $(RUN_ARGS)' variant command in the docker container" \
		FIRST_ARG=$(firstword $(MAKECMDGOALS)) \
		VARIANT_ENVIRONMENT=$(ENVIRONMENT) \
		DOCKER_CMD="$(strip ./$(FIRST_ARG) $(RUN_ARGS))"
else
.PHONY: $(FIRST_ARG)_main
$(FIRST_ARG)_main::
	@$(MAKE) docker.run \
		DOCKER_CMD_TITLE="Execute './$(FIRST_ARG) $(RUN_ARGS)' command in the docker container" \
		FIRST_ARG=$(firstword $(MAKECMDGOALS)) \
		DOCKER_CMD="$(strip ./$(FIRST_ARG) $(RUN_ARGS))"
endif

else

ifeq ($(TOOLBOX_RUN_VARIANT),true)

.PHONY: $(FIRST_ARG)_main
$(FIRST_ARG)_main::
	$(strip $(FIRST_ARG) $(RUN_ARGS))
else
.PHONY: $(FIRST_ARG)_main
$(FIRST_ARG)_main::
	$(strip $(FIRST_ARG) $(RUN_ARGS))
endif

endif

endif

TEMP_DIR ?= $(TOOLBOX_PROJECT)/$(TOOLBOX_DIR)/.tmp

BINDED_VARS_ROOT ?= .
BINDED_VARS_TEMP_FILE ?= .vars.tmp
BINDED_VARS_TEMP_FILE_PATH ?= $(TEMP_DIR)/$(BINDED_VARS_TEMP_FILE)
BINDED_VARS_CMD ?= yq r -j $(FIRST_ARG) | jq -r "'$(BINDED_VARS_ROOT)' | recurse(.tasks[]?) | select(.bindParamsFromEnv == true) | .parameters | .[]? | .name" | uniq

VARIANT_VARS_TEMP_FILE ?= .vars.variant.tmp
VARIANT_VARS_TEMP_FILE_PATH ?= $(TEMP_DIR)/$(VARIANT_VARS_TEMP_FILE)

.PHONY: docker.run.variant.vars
docker.run.variant.vars:
	@mkdir -p $(TEMP_DIR)
	@rm -f $(BINDED_VARS_TEMP_FILE_PATH)
	@rm -f $(VARIANT_VARS_TEMP_FILE_PATH)

	@(env | grep VARIANT_) > $(VARIANT_VARS_TEMP_FILE_PATH)
	@(env | grep TOOLBOX_) >> $(VARIANT_VARS_TEMP_FILE_PATH)

	$(eval ENV_CMD = $(if $(VARIANT_ENVIRONMENT),./$(FIRST_ARG) env set $(ENVIRONMENT); ,))

	@$(MAKE) docker.run \
		DOCKER_CMD_TITLE="Retrieve variable names from the variant file" \
		TOOLBOX_TOOL_DOCKER_IMAGE="$(VARS_RETRIEVE_IMAGE)" \
		DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS="" \
		DOCKER_CMD='$(BINDED_VARS_CMD) > $(BINDED_VARS_TEMP_FILE_PATH)'
	
	@$(MAKE) docker.run \
		DOCKER_CMD_TITLE="$(DOCKER_CMD_TITLE)" \
		DOCKER_ENV_FILE="$(VARIANT_VARS_TEMP_FILE_PATH)" \
		DOCKER_ENV_FILE2="$(BINDED_VARS_TEMP_FILE_PATH)" \
		DOCKER_ENV_VARS="$(DOCKER_ENV_VARS)" \
		DOCKER_CMD="$(ENV_CMD)$(DOCKER_CMD)" \
		TOOLBOX_TOOL_DOCKER_IMAGE="$(TOOLBOX_TOOL_DOCKER_IMAGE)" \
		DOCKER_RUN_MOUNT_VOLUME="$(DOCKER_RUN_MOUNT_VOLUME)" \
		DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS="$(DOCKER_SSH_AUTH_SOCK_FORWARD_PARAMS)"

	@rm -f $(BINDED_VARS_TEMP_FILE_PATH)
	@rm -f $(VARIANT_VARS_TEMP_FILE_PATH)

