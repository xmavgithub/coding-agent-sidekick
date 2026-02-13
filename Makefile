SHELL := /bin/sh

.PHONY: help kickoff coach implementation-gate bootstrap-existing-baseline new-context-pack update-baseline new-research new-plan new-adr validate-plan validate-pr install-hooks check-commits

help:
	@echo "Available targets:"
	@echo "  make kickoff FEATURE=\"<feature>\" MODULE=\"<module-optional>\" MODE=\"greenfield|existing\""
	@echo "  make coach FEATURE=\"<feature>\""
	@echo "  make implementation-gate FEATURE=\"<feature>\""
	@echo "  make bootstrap-existing-baseline SOURCE_PATH=\".\""
	@echo "  make new-context-pack FEATURE=\"<feature>\" TARGET_PATHS=\"path/a,path/b\""
	@echo "  make update-baseline FEATURE=\"<feature>\" SUMMARY=\"<summary>\" SOURCE_PATH=\".\" TARGET_PATHS=\"path/a,path/b\""
	@echo "  make new-research MODULE=\"<module>\" MODE=\"greenfield|existing\""
	@echo "  make new-plan FEATURE=\"<feature>\" MODE=\"greenfield|existing\""
	@echo "  make new-adr TITLE=\"<decision title>\""
	@echo "  make validate-plan FILE=\"docs/plans/<feature>-plan.md\""
	@echo "  make validate-pr"
	@echo "  make install-hooks"
	@echo "  make check-commits RANGE=\"HEAD~10..HEAD\""

kickoff:
	@./scripts/kickoff.sh "$(FEATURE)" "$(MODULE)" "$(MODE)"

coach:
	@./scripts/coach.sh "$(FEATURE)"

implementation-gate:
	@./scripts/implementation-gate.sh "$(FEATURE)"

bootstrap-existing-baseline:
	@./scripts/bootstrap-existing-baseline.sh "$(SOURCE_PATH)"

new-context-pack:
	@./scripts/new-context-pack.sh "$(FEATURE)" "$(TARGET_PATHS)"

update-baseline:
	@./scripts/update-baseline.sh "$(FEATURE)" "$(SUMMARY)" "$(SOURCE_PATH)" "$(TARGET_PATHS)"

new-research:
	@./scripts/new-research.sh "$(MODULE)" "$(MODE)"

new-plan:
	@./scripts/new-plan.sh "$(FEATURE)" "$(MODE)"

new-adr:
	@./scripts/new-adr.sh "$(TITLE)"

validate-plan:
	@./scripts/validate-plan.sh "$(FILE)"

validate-pr:
	@./scripts/validate-pr.sh

install-hooks:
	@./scripts/install-hooks.sh

check-commits:
	@./scripts/check-conventional-commits.sh --range "$(RANGE)"
