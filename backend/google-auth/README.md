 # YouText Backend (Stub)

This module provides a Spring Boot based HTTP API that mirrors the data model used in the Flutter client.  
At the moment storage and authentication are implemented in-memory stubs so the app can be wired end-to-end while the real backend is under construction.

## Requirements

- Java 17+
- Gradle 8+ (or use the Gradle wrapper once generated)

## Useful Commands

```bash
# from the backend directory
./gradlew bootRun        # start HTTP server on http://localhost:8080
./gradlew test           # run unit tests (none yet)
```

On Windows use `gradlew.bat bootRun`.

## API Overview

| Endpoint | Method | Description |
| --- | --- | --- |
| `/api/auth/google` | `POST` | Accepts a Google credential payload and returns a stubbed session token. |
| `/api/auth/me` | `GET` | Returns the active session for the provided `userId`. |
| `/api/auth/sign-out` | `POST` | Clears the in-memory session. |
| `/api/transcriptions` | `GET` | Lists transcriptions for the user. |
| `/api/transcriptions` | `POST` | Creates a new transcription entry. |
| `/api/transcriptions/{id}` | `GET` | Fetches one record. |
| `/api/transcriptions/{id}` | `DELETE` | Removes a record. |

### Authentication Stub

Requests to `/api/transcriptions/**` must include the header `X-User-Id` with a value obtained from `/api/auth/google`.  
No actual Google verification is performed yet; the backend simply fabricates a user and token.

## Next Steps

- Replace stub services with persistent storage (e.g., PostgreSQL or Firestore).
- Integrate real Google token verification.
- Secure API with Spring Security + OAuth.
