package com.snapmath.youtext.service;

import com.snapmath.youtext.model.UserProfile;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class InMemoryAuthService implements AuthService {

    private final Map<String, UserProfile> usersById = new ConcurrentHashMap<>();
    private final Map<String, String> tokensByUser = new ConcurrentHashMap<>();

    @Override
    public UserProfile signInWithGoogle(String credential, String email, String displayName) {
        // Stub: we do not validate the credential yet.
        UserProfile profile = usersById.values().stream()
                .filter(user -> user.getEmail().equalsIgnoreCase(email))
                .findFirst()
                .map(existing -> existing.toBuilder().displayName(displayName).build())
                .orElseGet(() -> UserProfile.builder()
                        .email(email)
                        .displayName(displayName)
                        .build());

        usersById.put(profile.getId(), profile);
        tokensByUser.put(profile.getId(), generateDemoToken(credential, profile.getId()));
        return profile;
    }

    @Override
    public Optional<UserProfile> findById(String userId) {
        return Optional.ofNullable(usersById.get(userId));
    }

    @Override
    public Optional<String> getActiveToken(String userId) {
        return Optional.ofNullable(tokensByUser.get(userId));
    }

    @Override
    public void signOut(String userId) {
        tokensByUser.remove(userId);
    }

    private String generateDemoToken(String seed, String userId) {
        return UUID.nameUUIDFromBytes((seed + ":" + userId).getBytes()).toString();
    }
}
