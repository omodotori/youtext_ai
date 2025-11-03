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
    text TEXT,
    timecode VARCHAR(50),
    link VARCHAR(255),
    CONSTRAINT fk_history_user
        FOREIGN KEY (user_id)
        REFERENCES "user" (id)
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