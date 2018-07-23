PROJECT = ramnesia_register
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = ramnesia cowboy jsx
dep_cowboy_commit = 2.4.0

DEP_PLUGINS = cowboy

dep_ramnesia = git https://github.com/hairyhum/ramnesia master

RELX_REPLACE_OS_VARS = true

NODE_NAME ?= rmns_listener
INITIAL_NODES ?= $(NODE_NAME)

PROD = false
export PROD

export RELX_REPLACE_OS_VARS

export NODE_NAME
export INITIAL_NODES

include erlang.mk

clean:: distclean-relx-rel
	rm -rf /tmp/ramnesia/

stop-cluster: all
	$(MAKE) stop-node NODE_NAME=rmns_listener; \
	$(MAKE) stop-node NODE_NAME=rmns2; \
	$(MAKE) stop-node NODE_NAME=rmns3

stop-node:
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) stop

start-node: all
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) start


run-cluster: all
	$(MAKE) start-node NODE_NAME=rmns_listener INITIAL_NODES=rmns_listener,rmns2,rmns3
	$(MAKE) start-node NODE_NAME=rmns2 INITIAL_NODES=rmns_listener,rmns2,rmns3
	$(MAKE) start-node NODE_NAME=rmns3 INITIAL_NODES=rmns_listener,rmns2,rmns3

prod-release: PROD = true
prod-release: clean rel
	mkdir -p release/
	cp $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/$(RELX_REL_NAME)-$(RELX_REL_VSN).tar.gz release/
	$(MAKE) clean
