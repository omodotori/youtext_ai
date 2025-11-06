# profile

Spring Boot service "profile"

### Run
Set environment variables (DB_URL, DB_USER, DB_PASS, MINIO_URL, MINIO_BUCKET, MINIO_ACCESS_KEY, MINIO_SECRET_KEY, PROFILE_PORT)
Then run:
```
mvn spring-boot:run
```

Endpoints:
- POST /api/profile/{user_id}/photo  (multipart form-data, key `file`)
- GET  /api/profile/{user_id}