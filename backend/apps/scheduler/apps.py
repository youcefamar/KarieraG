from django.apps import AppConfig


class SchedulerConfig(AppConfig):
    name = "apps.scheduler"
    verbose_name = "Scheduler"

    def ready(self):
        from .scheduler import start
        start()
