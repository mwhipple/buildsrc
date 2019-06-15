include bml

BATS   = $(call required-command,bats)

TEST_DIR := test/

.PHONY: check

check: ; ${BATS} -r ${TEST_DIR}
