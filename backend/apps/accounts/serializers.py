from rest_framework import serializers

from .models import Role, User


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ["id", "email", "username", "password", "role", "phone"]

    def validate_role(self, value):
        # Prevent self-registration as admin.
        if value == Role.ADMIN:
            raise serializers.ValidationError("Cannot self-register as admin.")
        return value

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "email", "username", "role", "phone"]
        read_only_fields = ["id", "role"]
