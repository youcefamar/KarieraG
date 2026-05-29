"""Payment / commission tracking (skeleton). MVP3."""
from django.conf import settings
from django.db import models


class PaymentRecord(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        PAID = "paid", "Paid"
        REFUNDED = "refunded", "Refunded"

    payer = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, related_name="payments"
    )
    enrollment = models.ForeignKey(
        "enrollments.Enrollment", on_delete=models.SET_NULL, null=True, blank=True
    )
    amount_dzd = models.DecimalField(max_digits=10, decimal_places=2)
    commission_dzd = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=10, choices=Status.choices, default=Status.PENDING)
    provider_ref = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"PaymentRecord<{self.amount_dzd}:{self.status}>"
