CREATE TABLE IF NOT EXISTS "user" (
    id SERIAL PRIMARY KEY,
    avatar_id TEXT UNIQUE,
    nickname VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    is_admin BOOLEAN DEFAULT false
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
    summary TEXT,
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

CREATE TABLE IF NOT EXISTS password_reset_token (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    code VARCHAR(10) NOT NULL,
    expiry_date TIMESTAMP NOT NULL
);