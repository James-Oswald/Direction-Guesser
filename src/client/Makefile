include ../../options.mk

BUILD_DIR:=	$(BUILD_DIR)/client


#
# TARGET DEFINITION
#
.PHONY: all
all: bundle-android-apk bundle-ios-app

.PHONY: configure
configure:
	$(FLUTTERC_CONFIG) $(FLUTTERC_CONFIG_FLAGS)

.PHONY: bundle-android-apk
bundle-android-apk: configure
	$(FLUTTERC_APK) $(FLUTTERC_FLAGS)

.PHONY: bundle-android-apk
bundle-ios-app: configure
	$(FLUTTERC_IPA) $(FLUTTERC_FLAGS) --no-codesign

default: all
