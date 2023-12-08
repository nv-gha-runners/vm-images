import boto3
from collectors import gc
from collections import defaultdict
from dateutil import parser
from mypy_boto3_ec2.type_defs import ImageTypeDef
from mypy_boto3_ec2.paginator import (
    DescribeImagesPaginator as EC2DescribeImagesPaginator,
)


class AMIGarbageCollector(gc.GarbageCollector):
    def __init__(self, current_images: list[str], dry_run: bool):
        super().__init__("AMI Collector", dry_run)
        self.ec2_client = boto3.client("ec2", region_name="us-east-2")
        self.current_images = current_images
        self.search_tag_name = "vm-images"
        self.search_tag_value = "true"

    def _run(self) -> None:
        amis = self._get_amis()
        expired_amis = self._find_expired_amis(amis)
        self._delete_amis(expired_amis)

    def _get_amis(self) -> list[ImageTypeDef]:
        amis = []
        paginator: EC2DescribeImagesPaginator = self.ec2_client.get_paginator(
            "describe_images"
        )
        for page in paginator.paginate(
            Owners=["self"],
            Filters=[
                {
                    "Name": f"tag:{self.search_tag_name}",
                    "Values": [self.search_tag_value],
                }
            ],
        ):
            page_amis = page["Images"]
            amis.extend(page_amis)
        return amis

    def _find_expired_amis(self, amis: list[ImageTypeDef]) -> list[ImageTypeDef]:
        expired_amis = []
        ami_groups = defaultdict(list)

        # Group AMIs by "image-name" tag
        for ami in amis:
            img_tags = ami["Tags"]
            if img_tags:
                for tag in img_tags:
                    if tag["Key"] == "image-name":
                        img_name = tag["Value"]
                        ami_groups[img_name].append(ami)
                        break

        # Sort AMIs by creation date.
        # If image is currently supported, keep only the newest AMI. Expire the rest.
        # If image is not currently supported, expire all AMIs.
        for img_name, amis in ami_groups.items():
            amis = sorted(
                amis, key=lambda x: parser.parse(x["CreationDate"]), reverse=True
            )
            if img_name in self.current_images:
                expired_amis.extend(amis[1:])
            else:
                expired_amis.extend(amis)

        return expired_amis

    def _delete_amis(self, amis: list[ImageTypeDef]) -> None:
        for ami in amis:
            self._deregister_ami(ami["ImageId"], ami["Name"])
            for snapshot in ami["BlockDeviceMappings"]:
                if snapshot.get("Ebs"):
                    self._delete_snapshot(snapshot["Ebs"]["SnapshotId"])

    def _deregister_ami(self, ami_id: str, ami_name: str) -> None:
        self.log_removal("AMI", f"{ami_id} ({ami_name})")
        if self.dry_run:
            return
        self.ec2_client.deregister_image(ImageId=ami_id)

    def _delete_snapshot(self, snapshot_id: str) -> None:
        self.log_removal("EBS Snapshot", snapshot_id)
        if self.dry_run:
            return
        self.ec2_client.delete_snapshot(SnapshotId=snapshot_id)
