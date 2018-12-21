PROJECT = mnevis_register
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = mnevis cowboy jsx
dep_cowboy_commit = 2.4.0

DEP_PLUGINS = cowboy

dep_mnevis = git https://github.com/rabbitmq/mnevis lock-wip

RELX_REPLACE_OS_VARS = true

NODE_NAME ?= mnevis_listener
INITIAL_NODES ?= $(NODE_NAME)

PROD = false
export PROD

export RELX_REPLACE_OS_VARS

export NODE_NAME
export INITIAL_NODES

include erlang.mk

clean:: distclean-relx-rel
	rm -rf /tmp/mnevis/

stop-cluster: all
	$(MAKE) stop-node NODE_NAME=mnevis_listener; \
	$(MAKE) stop-node NODE_NAME=mnevis2; \
	$(MAKE) stop-node NODE_NAME=mnevis3

stop-node:
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) stop

start-node-console: all
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) console

start-node: all
	$(verbose) $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/bin/$(RELX_REL_NAME)$(RELX_REL_EXT) start


run-cluster: all
	$(MAKE) start-node NODE_NAME=mnevis_listener INITIAL_NODES=mnevis_listener,mnevis2,mnevis3
	$(MAKE) start-node NODE_NAME=mnevis2 INITIAL_NODES=mnevis_listener,mnevis2,mnevis3
	$(MAKE) start-node NODE_NAME=mnevis3 INITIAL_NODES=mnevis_listener,mnevis2,mnevis3

prod-release: PROD = true
prod-release: clean rel
	mkdir -p release/
	cp $(RELX_OUTPUT_DIR)/$(RELX_REL_NAME)/$(RELX_REL_NAME)-$(RELX_REL_VSN).tar.gz release/
	$(MAKE) clean
