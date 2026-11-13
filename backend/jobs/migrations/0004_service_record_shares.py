from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):
    dependencies = [("jobs", "0003_job_declines"), migrations.swappable_dependency(settings.AUTH_USER_MODEL)]
    operations = [migrations.CreateModel(name="ServiceRecordShare", fields=[
        ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
        ("created_at", models.DateTimeField(auto_now_add=True)),
        ("mechanic", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="shared_service_records", to="mechanics.mechanicprofile")),
        ("record", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="shares", to="jobs.servicerecord")),
        ("shared_by", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="service_record_shares", to=settings.AUTH_USER_MODEL)),
    ], options={"unique_together": {("record", "mechanic")}})]
