include options.mk

#
# TARGET DEFINITION
#
SERVER_TARGETS=	server
CLIENT_TARGETS=	bundle-android-apk bundle-ios-app

.PHONY: all
all: server client

.PHONY: $(SERVER_TARGETS) $(CLIENT_TARGETS)
$(SERVER_TARGETS):
	$(MAKE) -C $(SRC_DIR)/server/ $@

$(CLIENT_TARGETS):
	$(MAKE) -C $(SRC_DIR)/client/ $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
