from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):
    dependencies = [("jobs", "0002_service_records_and_rejections")]
    operations = [migrations.CreateModel(name="JobDecline", fields=[
        ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
        ("created_at", models.DateTimeField(auto_now_add=True)),
        ("mechanic", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="declined_jobs", to="mechanics.mechanicprofile")),
        ("request", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="declines", to="jobs.servicerequest")),
    ], options={"unique_together": {("request", "mechanic")}})]
