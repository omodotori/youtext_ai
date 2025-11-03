package com.snapmath.youtext.service;

import com.snapmath.youtext.model.UserProfile;

import java.util.Optional;

public interface AuthService {

    UserProfile signInWithGoogle(String credential, String email, String displayName);

    Optional<UserProfile> findById(String userId);

    Optional<String> getActiveToken(String userId);

    void signOut(String userId);
}
