"""
APScheduler setup. Add periodic jobs here.

Jobs are stored in the database via DjangoJobStore so they survive restarts.
View/manage them in Django Admin under "Django APScheduler".
"""
import logging

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from django_apscheduler.jobstores import DjangoJobStore
from django_apscheduler.models import DjangoJobExecution

logger = logging.getLogger(__name__)


def delete_old_job_executions(max_age=604_800):
    """Delete job execution records older than max_age seconds (default: 1 week)."""
    DjangoJobExecution.objects.delete_old_job_executions(max_age)


def start():
    scheduler = BackgroundScheduler()
    scheduler.add_jobstore(DjangoJobStore(), "default")

    # ── Add your periodic jobs below ──────────────────────────────────────
    # Example: re-index AI embeddings every night at 2am
    # scheduler.add_job(
    #     reindex_embeddings,
    #     trigger=CronTrigger(hour=2, minute=0),
    #     id="reindex_embeddings",
    #     replace_existing=True,
    # )

    # Housekeeping: purge old job execution logs weekly
    scheduler.add_job(
        delete_old_job_executions,
        trigger=CronTrigger(day_of_week="mon", hour=0, minute=0),
        id="delete_old_job_executions",
        max_instances=1,
        replace_existing=True,
    )

    logger.info("Starting APScheduler...")
    scheduler.start()
