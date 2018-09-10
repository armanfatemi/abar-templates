SHELL := /bin/bash

include .makerc.dist

ifeq ($(shell test -e .makerc && echo -n yes),yes)
    include .makerc
endif

.PHONY: all imagestreams templates builds */ **/*.yml **/*/imagestream.yml

**/*/imagestream.yml:
	@echo "Processing and uploading imagestream in namespace $(NAMESPACE): ${@}" && \
	cat $@ \
    | sed "s|[<]NAMESPACE_HERE[>]|$(NAMESPACE)|" \
    | sed "s|[<]PRIVATE_ROUTE_HOSTNAME_HERE[>]|$(PRIVATE_ROUTE_HOSTNAME_HERE)|" \
    | sed "s|[<]REPOSITORY_URL_HERE[>]|$(REPOSITORY_URL)|" \
    | sed "s|[<]REPOSITORY_REF_HERE[>]|$(REPOSITORY_REF)|" \
    | oc process -n $(NAMESPACE) -f - \
    | oc apply -n $(NAMESPACE) -f -

**/*.yml:
	@echo "Uploading template in namespace $(NAMESPACE): ${@}" && \
	cat $@ \
	  | sed "s|[<]NAMESPACE_HERE[>]|$(NAMESPACE)|" \
	  | sed "s|[<]PRIVATE_ROUTE_HOSTNAME_HERE[>]|$(PRIVATE_ROUTE_HOSTNAME_HERE)|" \
	  | sed "s|[<]REPOSITORY_URL_HERE[>]|$(REPOSITORY_URL)|" \
	  | sed "s|[<]REPOSITORY_REF_HERE[>]|$(REPOSITORY_REF)|" \
	  | oc apply -n $(NAMESPACE) -f -

imagestreams: **/*/imagestream.yml

templates: **/*.yml

*/:
	$(MAKE) $@*/imagestream.yml || true
	$(MAKE) $@*.yml

all: imagestreams templates
