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
# FLUTTER IS BUGGY; APK BUILDS DO NOT RESPECT OUR SETTINGS
	mkdir -p $(BUILD_DIR)
	mv build $(BUILD_DIR)

.PHONY: bundle-android-apk
bundle-ios-app: configure
	$(FLUTTERC_IPA) $(FLUTTERC_FLAGS) --no-codesign

default: all
