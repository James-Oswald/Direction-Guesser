include ../../options.mk

BUILD_DIR:=	$(BUILD_DIR)/server


#
# TARGET DEFINITION
#
.PHONY: all
all: configure server

.PHONY: configure
configure:
	$(MIXC_FLAGS) $(MIXC) deps.get
	$(MIXC_FLAGS) $(MIXC) ecto.migrate

.PHONY: server
server: configure
	$(MIXC_FLAGS) $(MIXC) compile
#   MIX IS BUGGY, MIX_BUILD_PATH BREAKS DEPS
	mkdir -p $(BUILD_DIR)
	mv _build $(BUILD_DIR)

default: all
