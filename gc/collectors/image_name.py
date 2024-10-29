import dataclasses
import json
import os.path
import subprocess
from typing import Optional


DESERIALIZE_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "ci", "image-name", "deserialize.sh")


@dataclasses.dataclass
class ImageName:
    os: str
    variant: str
    driver_version: Optional[str]
    driver_flavor: Optional[str]
    arch: str
    branch_name: Optional[str]


def deserialize_image_name(image_name: str) -> Optional[ImageName]:
    result = subprocess.run([DESERIALIZE_PATH, image_name], stdout=subprocess.PIPE, text=True, check=True)
    parsed_json = json.loads(result.stdout)
    return ImageName(
        os=parsed_json["os"],
        variant=parsed_json["variant"],
        driver_version=parsed_json["driver_version"],
        driver_flavor=parsed_json["driver_flavor"],
        arch=parsed_json["arch"],
        branch_name=parsed_json["branch_name"],
    )
