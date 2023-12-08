import argparse
import subprocess
import json
from collectors.ecr import ECRGarbageCollector
from collectors.amis import AMIGarbageCollector
from collectors.gc import GarbageCollector


def load_current_images() -> list[str]:
    """
    Loads the currently supported images from the matrix and returns them as a list.
    """
    result = subprocess.run(
        "ci/compute-matrix.sh", cwd="..", capture_output=True, check=True
    )
    matrix = json.loads(result.stdout.decode("utf-8"))["include"]
    images = []
    for entry in matrix:
        result = subprocess.run(
            "ci/compute-image-name.sh",
            cwd="..",
            capture_output=True,
            env=entry,
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
    for GC in [ECRGarbageCollector, AMIGarbageCollector]:
        gc: GarbageCollector = GC(current_images, dry_run)
        gc.run()
        print()
