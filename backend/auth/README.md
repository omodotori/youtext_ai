# JWT Auth Spring Boot (Postgres)

Project configured as requested:
- Uses your existing `user` table (DO NOT DROP/ALTER it here).
- Adds `refresh_token` table (SQL provided in `sql/create_refresh_token.sql`).
- Access token (JWT) subject contains **userId** only.

How to run:
1. Edit `src/main/resources/application.properties` and set your Postgres connection and jwt.secret.
2. Run SQL file `sql/create_refresh_token.sql` on your DB to create `refresh_token` table.
3. Build: `mvn clean package`
4. Run: `java -jar target/jwt-auth-0.0.1-SNAPSHOT.jar`

Endpoints:
- POST /api/auth/register  -> {"email":"...","password":"..."}
- POST /api/auth/login     -> {"email":"...","password":"..."}  returns accessToken & refreshToken
- POST /api/auth/refresh   -> {"refreshToken":"..."} returns new pair
- POST /api/auth/logout    -> Authorization: Bearer <accessToken>
- GET  /api/user/me        -> Authorization: Bearer <accessToken>

Notes:
- Passwords are BCrypt-hashed.
- Refresh tokens are stored server-side and rotated on refresh.
