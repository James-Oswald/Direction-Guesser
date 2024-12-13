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
MIXC=	mix
MIXC_FLAGS=

FLUTTERC=	flutter build
FLUTTERC_APK=	$(FLUTTERC) apk
FLUTTERC_IPA=	$(FLUTTERC) ios
FLUTTERC_FLAGS=

FLUTTERC_CONFIG=	flutter config
FLUTTERC_CONFIG_FLAGS=	--build-dir=$(BUILD_DIR)

RELEASE ?=	0
ifeq ($(RELEASE), 1)
	MIXC_FLAGS +=	MIX_ENV=prod
	FLUTTERC_FLAGS +=	--release
else
	MIXC_FLAGS +=	MIX_ENV=dev 
	FLUTTERC_FLAGS +=	--debug
endif
