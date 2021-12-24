.ONESHELL:

# This prevents a conflict between pytest-bdd and pytest-mypy.
export PY_IGNORE_IMPORTMISMATCH=1

.PHONY: all
all: clean create-venv upgrade-pip

.PHONY: clean
clean:
	find . \( -name '__pycache__' -or -name '*.pyc' \) -delete

.PHONY: format
format:
	git diff master --name-only --oneline | grep -e ".*.py" | xargs black
	git diff master --name-only --oneline | grep -e ".*.py" | xargs isort

.PHONY: lint
lint:
	-git diff master --name-only --oneline | grep -e ".*.py" | xargs flake8
	-git diff master --name-only --oneline | grep -e ".*.py" | xargs mypy

.PHONY: upgrade-pip
upgrade-pip:
	pip install --upgrade pip
	pip install --upgrade setuptools wheel
	find . -name "requirements*.txt" -maxdepth 3 -exec pip install --upgrade -r {} \;

.PHONY: run
run: clean
	uvicorn src.main:app --host 0.0.0.0 --port $(PORT)

.PHONY: run-dev
run-dev: clean
	uvicorn src.main:app --reload --port 8000

.PHONY: test
test:
	coverage run --source=. -m pytest tests/
	coverage report -m --fail-under=100
