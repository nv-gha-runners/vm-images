import argparse
import subprocess
import json
import yaml
from os import path, getenv
from collectors.ecr import ECRGarbageCollector
from collectors.amis import AMIGarbageCollector
from collectors.gc import GarbageCollector


def load_current_images() -> list[str]:
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
        compute_matrix_path, cwd="..", capture_output=True, check=True
    )
    matrix = json.loads(result.stdout.decode("utf-8"))["include"]
    images = []
    for entry in matrix:
        result = subprocess.run(
            compute_image_name_path,
            cwd="..",
            capture_output=True,
            env={**entry, "BRANCH_NAME": getenv("BRANCH_NAME")},
            check=True,
        )
        images.append(result.stdout.decode("utf-8").strip())
    return images


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
    current_images = load_current_images()
    if not current_images:
        print()
        print("No current images found. Something's not right.")
        print("Exiting to prevent all images from being deleted from AWS.")
        exit(1)

    regions_path = path.join(path.dirname(__file__), "..", "regions.yaml")
    with open(regions_path, "r") as file:
        regions = yaml.safe_load(file)

    ecr_collectors = [
        ECRGarbageCollector(
            current_images=current_images,
            region=regions["public_ecr_region"],
            dry_run=dry_run,
        )
    ]
    ami_collectors = [
        AMIGarbageCollector(
            current_images=current_images,
            region=region,
            dry_run=dry_run,
        )
        for region in [regions["default_region"]] + regions["backup_regions"]
    ]

    for gc in ecr_collectors + ami_collectors:
        gc.run()
        print()
