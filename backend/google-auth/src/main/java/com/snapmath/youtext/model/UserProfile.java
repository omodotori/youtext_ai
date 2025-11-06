package com.snapmath.youtext.model;

import java.time.Instant;
import java.util.UUID;

public class UserProfile {
    private final String id;
    private final String email;
    private final String displayName;
    private final Instant createdAt;

    private UserProfile(Builder builder) {
        this.id = builder.id != null ? builder.id : UUID.randomUUID().toString();
        this.email = builder.email;
        this.displayName = builder.displayName;
        this.createdAt = builder.createdAt != null ? builder.createdAt : Instant.now();
    }

    public String getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getDisplayName() {
        return displayName;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Builder toBuilder() {
        return new Builder()
                .id(id)
                .email(email)
                .displayName(displayName)
                .createdAt(createdAt);
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String id;
        private String email;
        private String displayName;
        private Instant createdAt;

        public Builder id(String id) {
            this.id = id;
            return this;
        }

        public Builder email(String email) {
            this.email = email;
            return this;
        }

        public Builder displayName(String displayName) {
            this.displayName = displayName;
            return this;
        }

        public Builder createdAt(Instant createdAt) {
            this.createdAt = createdAt;
            return this;
        }

        public UserProfile build() {
            return new UserProfile(this);
        }
    }
}
