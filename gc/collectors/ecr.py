import boto3
from collectors import gc
from mypy_boto3_ecr_public.type_defs import ImageDetailTypeDef
from mypy_boto3_ecr_public.paginator import (
    DescribeImagesPaginator as ECRPublicDescribeImagesPaginator,
)


class ECRGarbageCollector(gc.GarbageCollector):
    def __init__(self, current_images: list[str], region: str, dry_run: bool):
        super().__init__("ECR Collector", region, dry_run)
        self.ecr_client = boto3.client("ecr-public", region_name=region)
        self.current_images = current_images
        self.repository_name = "kubevirt-images"

    def _run(self) -> None:
        ecr_images = self._get_ecr_images()
        expired_ecr_images = self._find_expired_ecr_images(ecr_images)
        if expired_ecr_images:
            self._delete_images(expired_ecr_images)
            return
        print("No expired ECR images found.")

    def _get_ecr_images(self) -> list[ImageDetailTypeDef]:
        images = []
        paginator: ECRPublicDescribeImagesPaginator = self.ecr_client.get_paginator(
            "describe_images"
        )
        for page in paginator.paginate(repositoryName=self.repository_name):
            page_images = page["imageDetails"]
            images.extend(page_images)
        return images

    def _find_expired_ecr_images(
        self, images: list[ImageDetailTypeDef]
    ) -> list[ImageDetailTypeDef]:
        expired_images = []

        for image in images:
            image_tags = image.get("imageTags")
            hasSupportedTags = False
            if image_tags:
                for tag in image_tags:
                    if tag in self.current_images:
                        hasSupportedTags = True
                        break

            # Remove images that don't have any tags or don't have any supported tags
            if not image_tags or not hasSupportedTags:
                expired_images.append(image)
                continue
        return expired_images

    def _delete_images(self, images: list[ImageDetailTypeDef]) -> None:
        for img in images:
            tag_name = (
                img.get("imageTags") and ", ".join(img["imageTags"]) or "untagged"
            )
            self.log_removal("ECR Image", f"{img['imageDigest']} ({tag_name})")
        if self.dry_run:
            return
        self.ecr_client.batch_delete_image(
            repositoryName=self.repository_name,
            imageIds=[{"imageDigest": img["imageDigest"]} for img in images],
        )
