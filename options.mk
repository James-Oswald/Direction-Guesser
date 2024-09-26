#
# SOURCE DEFINITION
#
GIT_VERSION=	$(shell git rev-parse --short HEAD)
GIT_TOP_DIR=	$(shell git rev-parse --show-cdup)
ifeq ($(GIT_TOP_DIR),)
	GIT_TOP_DIR=	.
else
	GIT_TOP_DIR:=	$(GIT_TOP_DIR:/=)
endif

SRC_DIR=	$(GIT_TOP_DIR)/src
BUILD_DIR=	$(GIT_TOP_DIR)/.build


#
# COMPILER DEFINITION
#
RUSTC=		cargo install --path .
RUSTC_FLAGS=	--target-dir "$(BUILD_DIR)/" --root "$(BUILD_DIR)/"

FLUTTERC=	flutter build
FLUTTERC_APK=	$(FLUTTERC) apk
FLUTTERC_IPA=	$(FLUTTERC) ios
FLUTTERC_FLAGS=

FLUTTERC_CONFIG =	flutter config
FLUTTERC_CONFIG_FLAGS = --build-dir=$(BUILD_DIR)

RELEASE ?=	0
ifeq ($(RELEASE), 1)
	# CARGO INSTALL DEFAULTS TO A RELEASE PROFILE
	FLUTTERC_FLAGS +=	--release
else
	RUSTC_FLAGS +=		--debug
	FLUTTERC_FLAGS +=	--debug
endif
