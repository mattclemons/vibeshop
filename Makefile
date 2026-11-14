SHELL := /bin/bash
COMPOSE := bash scripts/compose.sh
.PHONY: bootstrap doctor build up down reset clean seed smoke audit verify logs ps
bootstrap:
	@bash bootstrap.sh --local
doctor:
	@bash scripts/doctor.sh
build:
	$(COMPOSE) build
up:
	@bash scripts/alias.sh
	@bash scripts/guard.sh
	$(COMPOSE) up -d --build --force-recreate
	@bash scripts/wait.sh
down:
	$(COMPOSE) down
reset: down
	@bash scripts/alias.sh
	@bash scripts/guard.sh
	$(COMPOSE) up -d --build --force-recreate
	@bash scripts/wait.sh
	@bash scripts/reseed.sh
seed:
	@bash scripts/reseed.sh
smoke:
	@bash scripts/smoke.sh
audit:
	@bash scripts/audit.sh
verify:
	@test -n "$(N)" || { echo "usage: make verify N=01"; exit 2; }
	@test -s exploits/$(N)/run.sh -a -s tests/$(N)/test.sh || { echo "Original module $(N) artifacts are not included. See RELEASE-CHECKLIST.md"; exit 2; }
	@bash exploits/$(N)/run.sh
	@bash tests/$(N)/test.sh
clean:
	$(COMPOSE) down -v
	@bash scripts/unalias.sh
logs:
	$(COMPOSE) logs --tail=60
ps:
	$(COMPOSE) ps
