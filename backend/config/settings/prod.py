"""Production settings."""
from .base import *  # noqa: F401,F403
import sentry_sdk

DEBUG = False

SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")

# Static files served by WhiteNoise (no separate CDN needed at MVP scale)
MIDDLEWARE.insert(1, "whitenoise.middleware.WhiteNoiseMiddleware")  # noqa: F405
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

# Media / object storage — switch via STORAGE_BACKEND env var
_storage = env("STORAGE_BACKEND", default="local")  # noqa: F405

if _storage == "s3":
    DEFAULT_FILE_STORAGE = "storages.backends.s3boto3.S3Boto3Storage"
    AWS_STORAGE_BUCKET_NAME = env("AWS_STORAGE_BUCKET_NAME")  # noqa: F405
    AWS_S3_REGION_NAME = env("AWS_S3_REGION_NAME", default="us-east-1")  # noqa: F405
    AWS_S3_FILE_OVERWRITE = False
elif _storage == "cloudinary":
    DEFAULT_FILE_STORAGE = "cloudinary_storage.storage.MediaCloudinaryStorage"
    CLOUDINARY_STORAGE = {
        "CLOUD_NAME": env("CLOUDINARY_CLOUD_NAME"),  # noqa: F405
        "API_KEY": env("CLOUDINARY_API_KEY"),  # noqa: F405
        "API_SECRET": env("CLOUDINARY_API_SECRET"),  # noqa: F405
    }

# Error tracking
_sentry_dsn = env("SENTRY_DSN", default="")  # noqa: F405
if _sentry_dsn:
    sentry_sdk.init(dsn=_sentry_dsn, traces_sample_rate=0.2)
