include bml

BATS   = $(call required-command,bats)

REPO_WEB      := https://github.com/brightcove/buildsrc
REPO_SSH_ROOT := git@github.com:brightcove/buildsrc
TEST_DIR      := test/
WIKI_DIR      := wiki/

help: ; @cat buildsrc/help
check: ; ${BATS} -r ${TEST_DIR}
todo: ; @echo 'View issues at ${REPO_WEB}/issues'

${WIKI_DIR}: ; git clone ${REPO_SSH_ROOT}.wiki.git $@

.PHONY: check help todo
