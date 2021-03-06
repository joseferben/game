.PHONY: help
help:
	@echo "Welcome to game"
	@echo "======================================================="
	@echo ""
	@echo "Here are some of the most convenient commands:"
	@echo ""
	@echo "- docker              Starts environment with Postgres and Redis using docker-compose, destroys current environment"
	@echo "- data                Runs migrations, creates default user, groups and data"
	@echo "- check               Runs linter and type checker and fixes found issues"
	@echo "- fix                 Fixes issues like formatting and imports"
	@echo "- migrate             Runs migrations"
	@echo "- env                 Starts environment and seeds examples data, destroys current environment!"
	@echo "- test                Runs all tests, requires a database"
	@echo "- shell               Starts an interactive shell with all models imported"
	@echo "- workers             Starts a cluster of worker processes"
	@echo "- beat								 Starts a beat process for scheduled tasks"
	@echo "- run                 Starts the development web server on localhost:8000"
	@echo "- migrations          Creates migrations based on models.py change"
	@echo ""
	@echo "Here are some of less used commands:"
	@echo ""
	@echo "- graph               Renders a graph with all models in graph.png"
	@echo "- coverage            Runs tests and prints coverage in terminal"
	@echo "- check.lint          Runs linter"
	@echo "- check.types         Runs type checker"

.PHONY: check.lint
check.lint:
	python manage.py check --fail-level WARNING
	pre-commit run --show-diff-on-failure -a

.PHONY: check.types
check.types:
	pyright

.PHONY: check
check: check.lint check.types

.PHONY: fix
fix:
	isort --profile black .
	black . --preview
	autoflake --in-place --remove-unused-variables --remove-all-unused-imports --remove-duplicate-keys .
	djhtml game/templates/**/*.html -i -t 2

.PHONY: test
test:
	pytest

.PHONY: coverage
coverage:
	coverage run -m pytest
	coverage report

.PHONY: shell
shell:
	python manage.py shell_plus

.PHONY: migrations
migrations:
	python manage.py makemigrations

.PHONY: migrate
migrate:
	python manage.py migrate

.PHONY: run
run:
	python manage.py runserver_plus --nopin

.PHONY: workers
workers:
	celery -A config.celery_app worker --loglevel=info

.PHONY: beat
beat:
	celery -A config.celery_app beat --loglevel=info

.PHONY: graph
graph:
	python manage.py graph_models -a --pygraphviz --output models.png

.PHONY: docker
docker:
	docker-compose -f docker-compose.dev.yml down
	docker-compose -f docker-compose.dev.yml up -d

.PHONY: data
data:
	python manage.py migrate
