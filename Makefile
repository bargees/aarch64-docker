GITHASH := 8784753
VERSION := 17.07.0-ce

ARCHIVE := docker-$(VERSION).tgz
HASH    := docker-$(VERSION).hash

CLI     := docker-ce/components/cli/build/docker
ENGINE  := \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/docker-containerd \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/docker-containerd-ctr \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/docker-containerd-shim \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/docker-init \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/docker-proxy \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/docker-runc \
	docker-ce/components/engine/bundles/$(VERSION)/binary-daemon/dockerd
BINARIES := $(CLI) $(ENGINE)

all: $(ARCHIVE) $(HASH)

$(HASH): $(ARCHIVE)
	echo -n "sha256  " > $@
	sha256sum $(ARCHIVE) >> $@

$(ARCHIVE): $(BINARIES)
	rm -rf docker-ce/bundles/$(VERSION)/docker
	mkdir -p docker-ce/bundles/$(VERSION)/docker
	cp $^ docker-ce/bundles/$(VERSION)/docker/
	tar zcvf $@ -C docker-ce/bundles/$(VERSION)/ docker

$(CLI): | docker-cli-builder docker-ce
	cd docker-ce && git fetch && git checkout $(GITHASH)
	docker run -t --rm -e VERSION=$(VERSION) -e GITCOMMIT=$(GITHASH) \
		-v $(CURDIR)/docker-ce/components/cli:/go/src/github.com/docker/cli docker-cli-builder make

$(ENGINE): | docker-ce
	cd docker-ce && git fetch && git checkout $(GITHASH)
	$(MAKE) -C docker-ce/components/engine binary

docker-cli-builder:
	docker build -t docker-cli-builder docker-cli-builder

docker-ce:
	git clone https://github.com/docker/docker-ce.git

clean:
	$(RM) $(ARCHIVE) $(HASH) $(BINARIES)

distclean: clean
	$(RM) -r docker-ce
	docker rmi docker-cli-builder

.PHONY: all docker-cli-builder clean distclean
