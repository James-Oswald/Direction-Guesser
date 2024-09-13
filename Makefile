#
# SOURCE DEFINITION
#
SRC_VERSION = $(git rev-parse --short HEAD)
TARGET_BUILD_DIR = .build/$@
TARGET_SRC_DIR = src/$@


#
# COMPILER DEFINITION
#
RUSTC = cargo build
RUSTC_FLAGS = --target-dir "$(TARGET_BUILD_DIR)"

FLUTTERC = flutter build
FLUTTERC_APK = $(FLUTTERC) ios
FLUTTERC_IOS = $(FLUTTERC) ios
FLUTTERC_FLAGS = --build-dir=$(TARGET_BUILD_DIR)

RELEASE ?= 0
ifeq ($(RELEASE), 1)
	RUSTC_FLAGS += --release
	FLUTTERC_FLAGS += --release
else
	# RUST DEFAULTS TO A DEBUG PROFILE
	FLUTTERC_FLAGS += --debug
endif


#
# TARGET DEFINITION
#
all: server client

server:
	$(RUSTC) $(RUSTC_FLAGS) --manifest-path "$(TARGET_SRC_DIR)/Cargo.toml"

client:
	$(FLUTTERC_APK) $(FLUTTERC_FLAGS) --project-dir="$(TARGET_SRC_DIR)/"
	$(FLUTTERC_IOS) $(FLUTTERC_FLAGS) --project-dir="$(TARGET_SRC_DIR)/"

clean:
	rm -rf .build

default: all
