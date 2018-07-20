PROJECT = ramnesia_register
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = ramnesia cowboy

dep_ramnesia = git https://github.com/hairyhum/ramnesia master

NODE_NAME ?= rmns
RELX_REPLACE_OS_VARS = true
INITIAL_NODES ?= $(NODE_NAME)

export NODE_NAME
export RELX_REPLACE_OS_VARS
export INITIAL_NODES

include erlang.mk

clean:: distclean-relx-rel
	rm -rf /tmp/ramnesia/

stop-cluster: all
	$(MAKE) stop-node NODE_NAME=rmns1; \
	$(MAKE) stop-node NODE_NAME=rmns2; \
	$(MAKE) stop-node NODE_NAME=rmns3

stop-node:
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) stop

start-node: all
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) start


run-cluster: all
	$(MAKE) start-node NODE_NAME=rmns1 INITIAL_NODES=rmns1,rmns2,rmns3
	$(MAKE) start-node NODE_NAME=rmns2 INITIAL_NODES=rmns1,rmns2,rmns3
	$(MAKE) start-node NODE_NAME=rmns3 INITIAL_NODES=rmns1,rmns2,rmns3