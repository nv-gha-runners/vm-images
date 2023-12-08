# gc

This repository contains a Python script that's responsible for pruning old ECR and AMI images from AWS.

## Usage

Create a local environment:

```sh
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Then run the script:

```sh
# by default, script runs with `--dry-run=true`
python main.py

# set `--dry-run=false` to actually remove AWS resources
python main.py --dry-run=false
```

Use `black` to check your formatting:

```sh
black main.py collectors/*.py
```

Use `mypy` for type checking:

```sh
mypy main.py collectors/*.py
```
