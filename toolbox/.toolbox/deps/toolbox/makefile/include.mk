ifeq ($(OS),Windows_NT)
    DETECTED_OS = WIN32
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        DETECTED_OS = LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        DETECTED_OS = OSX
    endif
endif

define colorecho
	# @tput setaf 6
	@echo $1
	# @tput sgr0
endef

