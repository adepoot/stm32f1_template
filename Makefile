PROJECT_NAME ?= bluepill_makefile-example
BUILD_DIR ?= build
BUILD_SYSTEM = Unix Makefiles
BUILD_TYPE ?= Debug

RUNNING_IN_CONTAINER := false
ifneq (,$(wildcard /etc/alpine-release))
	RUNNING_IN_CONTAINER := true
endif

BUILD_CMD := $(if $(filter $(RUNNING_IN_CONTAINER), true), build-local, build-via-container)

build: echo-env $(BUILD_CMD)

echo-env:
ifeq ($(RUNNING_IN_CONTAINER), true)
	@echo "Running in a container; building with the local tools..."
else
	@echo "Not running in a container; using a container for building..."
endif

################################## Local ##################################

build-local: clean cmake
	$(MAKE) -C $(BUILD_DIR) --no-print-directory

cmake: $(BUILD_DIR)/Makefile

$(BUILD_DIR)/Makefile: CMakeLists.txt
	cmake \
		-G "$(BUILD_SYSTEM)" \
		-B$(BUILD_DIR) \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE)

# Formats all user modified source files (add ones that are missing)
SRCS := $(shell find project -name '*.[ch]' -or -name '*.[ch]pp') Core/Src/main.c
format: $(addsuffix .format,$(SRCS))
%.format: %
	clang-format -i $<

# Formats all CubeMX generated sources to unix style - removes \r from line endings
# Add any new directories, like Middlewares and hidden files
HIDDEN_FILES := .mxproject .project .cproject
FOUND_HIDDEN_FILES := $(shell for f in $(HIDDEN_FILES);do if [[ -e $$f ]]; then echo $$f;fi; done)
FORMAT_LINUX := $(shell find Core Drivers -name '*' -type f; find . -name '*.ioc') $(FOUND_HIDDEN_FILES)

format-linux: $(addsuffix .format-linux,$(FORMAT_LINUX))
%.format-linux: %
	$(if $(filter $(PLATFORM),Linux),dos2unix -q $<,)

clean:
	rm -rf $(BUILD_DIR)

################################## Container ##################################

IMAGE_NAME := arm-embedded-dev-img
CONTAINER_NAME := arm-embedded-dev
WORKDIR_PATH = /workdir
WORKDIR_VOLUME = "$$(pwd):$(WORKDIR_PATH)"

NEED_IMAGE = $(shell docker image inspect $(IMAGE_NAME) 2> /dev/null > /dev/null || echo build-image)

CONTAINER_RUN = docker run \
					--name $(CONTAINER_NAME) \
					--rm \
					-it \
					-v $(WORKDIR_VOLUME) \
					-w $(WORKDIR_PATH) \
					$(IMAGE_NAME)

build-via-container: clean $(NEED_IMAGE)
	$(CONTAINER_RUN) /bin/sh -lc 'make build-local -j16'

shell: $(NEED_IMAGE)
	$(CONTAINER_RUN) /bin/sh -l

build-image: Dockerfile
	docker build \
		-t $(IMAGE_NAME) \
		-f Dockerfile \
		.

clean-image:
	docker container rm -rf $(CONTAINER_NAME) 2> /dev/null > /dev/null || true
	docker image rm $(IMAGE_NAME) 2> /dev/null > /dev/null || true

clean-all: clean clean-image

################################## Flashing ##################################

flash: build
	st-flash --flash=128k --reset write $(BUILD_DIR)/$(PROJECT_NAME).bin 0x08000000
