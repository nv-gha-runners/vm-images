import argparse
import subprocess
import json
import yaml
from os import path, getenv

from collectors.ecr import ECRGarbageCollector
from collectors.amis import AMIGarbageCollector
from collectors.gc import GarbageCollector
from github import Github


def load_current_images(runner_env: str) -> list[str]:
    """
    Loads the currently supported images from the matrix and returns them as a list.
    """
    compute_matrix_path = path.join(
        path.dirname(__file__), "..", "ci", "compute-matrix.sh"
    )
    compute_image_name_path = path.join(
        path.dirname(__file__), "..", "ci", "compute-image-name.sh"
    )
    result = subprocess.run(
        compute_matrix_path, cwd="..", stdout=subprocess.PIPE, text=True, check=True
    )
    matrix: list[dict[str, str]] = json.loads(result.stdout)["include"]
    images = []
    branch_name = getenv("BRANCH_NAME")
    assert branch_name is not None
    for entry in matrix:
        if entry["ENV"] == runner_env:
            result = subprocess.run(
                compute_image_name_path,
                cwd="..",
                stdout=subprocess.PIPE,
                text=True,
                env=dict(filter(lambda item: item[0] != "ENV", entry.items()))
                | {"RUNNER_ENV": runner_env, "BRANCH_NAME": branch_name},
                check=True,
            )
            images.append(result.stdout.strip())
    return images


def load_current_branches() -> list[str]:
    """
    Loads the currently existing branches from the repository and returns them as a list.
    """
    client = Github()
    repository = getenv("REPOSITORY")
    assert repository is not None
    return [b.name for b in client.get_repo(repository).get_branches()]


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process some integers.")
    parser.add_argument(
        "--dry-run",
        dest="dry_run",
        type=str,
        default="true",
        help="an optional argument to run the script in dry-run mode (default: true)",
    )
    args = parser.parse_args()
    dry_run = args.dry_run != "false"
    current_branches = load_current_branches()
    if not current_branches:
        print()
        print("No current branches found. Something's not right.")
        print("Exiting to prevent all images from being deleted from AWS.")
        exit(1)

    regions_path = path.join(path.dirname(__file__), "..", "regions.yaml")
    with open(regions_path, "r") as file:
        regions = yaml.safe_load(file)

    ecr_collectors = [
        ECRGarbageCollector(
            current_branches=current_branches,
            region=regions["public_ecr_region"],
            dry_run=dry_run,
        )
    ]
    ami_collectors = [
        AMIGarbageCollector(
            current_images=load_current_images("aws"),
            current_branches=current_branches,
            region=region,
            dry_run=dry_run,
        )
        for region in [regions["default_region"]] + regions["backup_regions"]
    ]

    for gc in ecr_collectors + ami_collectors:
        gc.run()
        print()
