DOCKERHUB_REPO := nervos/ckb-docker-builder
GHCR_REPO := ghcr.io/nervosnetwork/ckb-docker-builder
IMAGE_VERSION := rust-$(shell sed -n "s/RUST_VERSION = '\(.*\)'$$/\1/p" gen-dockerfiles)

bionic/Dockerfile: gen-dockerfiles templates/bionic.Dockerfile
	python3 gen-dockerfiles

centos-7/Dockerfile: gen-dockerfiles templates/centos-7.Dockerfile
	python3 gen-dockerfiles

build-all: build-bionic build-centos-7

build-bionic: bionic/Dockerfile
	docker build -f bionic/Dockerfile --tag ${DOCKERHUB_REPO}:bionic-${IMAGE_VERSION} .

build-centos-7: centos-7/Dockerfile
	docker build -f centos-7/Dockerfile --tag ${DOCKERHUB_REPO}:centos-7-${IMAGE_VERSION} .

.PHONY: build-all build-bionic build-centos-7

push-all: push-bionic push-centos-7

push-bionic: build-bionic
	docker push ${DOCKERHUB_REPO}:bionic-${IMAGE_VERSION}

push-centos-7: build-centos-7
	docker push ${DOCKERHUB_REPO}:centos-7-${IMAGE_VERSION}

.PHONY: push-all push-bionic push-centos-7

test-all: test-bionic test-centos-7

sync-ckb:
	if [ -d ckb ]; then git -C ckb pull; else git clone --depth 1 https://github.com/nervosnetwork/ckb.git; fi

test-bionic: sync-ckb
	docker --rm -it -w /ckb -v "$$(pwd)/ckb:/ckb" ${DOCKERHUB_REPO}:bionic-${IMAGE_VERSION} make prod

test-centos-7: sync-ckb
	docker --rm -it -w /ckb -v "$$(pwd)/ckb:/ckb" ${DOCKERHUB_REPO}:centos-7-${IMAGE_VERSION} make prod

.PHONY: test-all test-bionic test-centos-7 sync-ckb
