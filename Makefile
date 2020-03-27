include bml

BATS   = $(call required-command,bats)
DOCKER = $(call required-command,docker)

REPO_WEB      := https://github.com/mwhipple/buildsrc
REPO_SSH_ROOT := git@github.com:mwhipple/buildsrc
TEST_DIR      := test/
WIKI_DIR      := wiki/
BUILD_DIR     := build/
TMP_DIR       := ${BUILD_DIR}tmp

${BUILD_DIR}: ; mkdir -p $@

# This can be used to dump info while troubleshooting tests.
${TMP_DIR}: ; mkdir -p $@ && chmod a+rw $@

help: ; @cat buildsrc/help
todo: ; @echo 'View issues at ${REPO_WEB}/issues'

${WIKI_DIR}: ; git clone ${REPO_SSH_ROOT}.wiki.git $@

.PHONY: help todo

check: export TEST_LOG=$(abspath ${TMP_DIR})/log
check: | ${TMP_DIR}
	${BATS} -r ${TEST_DIR}

TEST_TAG := bats_w_git:latest

TEST_IMAGE := ${BUILD_DIR}test.iid
${TEST_IMAGE}: ${TEST_DIR}Dockerfile | ${BUILD_DIR}
	docker build --iidfile=$@ \
		--tag=${TEST_TAG} \
		--file=$< \
		.

docker-check: export TEST_LOG=/buildsrc/${TMP_DIR}log
docker-check: ${TEST_IMAGE} | ${TMP_DIR}
	${DOCKER} run \
		-u bats \
		-v "$(abspath .):/buildsrc" \
		${TEST_TAG} -r "/buildsrc/${TEST_DIR}"

.PHONY: check docker-check
