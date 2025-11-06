CREATE TABLE IF NOT EXISTS "user" (
    id SERIAL PRIMARY KEY,
    avatar_id TEXT UNIQUE,
    nickname VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    email VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS refresh_token (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "user"(id) ON DELETE CASCADE UNIQUE,
    token TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL
);


CREATE TABLE IF NOT EXISTS history (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    video_title VARCHAR(255) NOT NULL,
    link TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    text TEXT,
    transcript TEXT,
    CONSTRAINT fk_summary_user
        FOREIGN KEY (user_id)
        REFERENCES "user" (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS highlights (
    id SERIAL PRIMARY KEY,
    history_id INT NOT NULL,
    highlight TEXT NOT NULL,
    CONSTRAINT fk_highlights_history
        FOREIGN KEY (history_id)
        REFERENCES history (id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS timecodes (
    id SERIAL PRIMARY KEY,
    history_id INT NOT NULL,
    timecode VARCHAR(50),
    descriptions TEXT,
    CONSTRAINT fk_timecodes_history
        FOREIGN KEY (history_id)
        REFERENCES history (id)
        ON DELETE CASCADE
);

-- add_is_admin.sql
ALTER TABLE "user"
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- Присвоить флаг существующему администратору по email (замените email на ваш реальный)
UPDATE "user" SET is_admin = TRUE WHERE email = 'admin@gmail.com';