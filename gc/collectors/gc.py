from abc import ABC, abstractmethod


class GarbageCollector(ABC):
    def __init__(self, collector_name: str, dry_run: bool):
        self.dry_run = dry_run
        self.collector_name = collector_name
        self.removal_action = dry_run and "Would have deleted" or "Deleting"

    def log_removal(self, resource_name: str, resource_id: str) -> None:
        print(f"{self.removal_action} {resource_name}: {resource_id}")

    def run(self) -> None:
        print(f"Running {self.collector_name}: dry_run={self.dry_run}")
        self._run()

    @abstractmethod
    def _run(self) -> None:
        pass
