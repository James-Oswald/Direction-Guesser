#
# Source Definition
#
SRC_VERSION = $(git rev-parse --short HEAD)
TARGET_BUILD_DIR = .build/$@
TARGET_SRC_DIR = src/$@

#
# Compiler Definition
#
RUSTC = cargo build
RUSTC_FLAGS = --target-dir "$(TARGET_BUILD_DIR)"

DOTNETC = dotnet build
DOTNETC_FLAGS = --artifacts-path "$(TARGET_BUILD_DIR)"
DOTNETC_RESTORE = dotnet workload restore
DOTNETC_RESTORE_FLAGS = --artifacts-path "$(TARGET_BUILD_DIR)"

RELEASE ?= 0
ifeq ($(RELEASE), 1)
	RUSTC_FLAGS   += --release
	DOTNETC_FLAGS += -sc
else
	DOTNETC_FLAGS += --debug
endif

#
# Target Definition
#
default: frontend backend

frontend:
	$(DOTNETC_RESTORE) $(DOTNETC_RESTORE_FLAGS) "$(TARGET_SRC_DIR)/frontend.csproj"
	$(DOTNETC)         $(DOTNETC_FLAGS)         "$(TARGET_SRC_DIR)/frontend.csproj"

backend:
	$(RUSTC) $(RUSTC_FLAGS) --manifest-path "$(TARGET_SRC_DIR)/Cargo.toml"
