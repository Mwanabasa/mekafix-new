from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [("mechanics", "0001_initial")]
    operations = [
        migrations.AddField(model_name="mechanicprofile", name="garage_type", field=models.CharField(choices=[("standard", "Standard garage"), ("specialist", "Specialist garage")], default="standard", max_length=20)),
        migrations.AddField(model_name="mechanicprofile", name="supported_vehicle_types", field=models.JSONField(blank=True, default=list)),
        migrations.AddField(model_name="mechanicprofile", name="qualifications", field=models.TextField(blank=True)),
        migrations.AddField(model_name="mechanicprofile", name="specialist_approved", field=models.BooleanField(default=False)),
        migrations.AddField(model_name="mechanicprofile", name="business_hours", field=models.CharField(blank=True, max_length=160)),
        migrations.AddField(model_name="mechanicprofile", name="business_description", field=models.TextField(blank=True)),
    ]
