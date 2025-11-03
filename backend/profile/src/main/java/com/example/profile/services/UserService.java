package com.example.profile.services;

import com.example.profile.models.User;
import com.example.profile.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UserService {

    private final UserRepository repository;
    private final S3Service s3Service;

    @Value("${default.avatar.url:classpath:/static/default-avatar.jpg}")
    private String defaultAvatarUrl;

    public UserService(UserRepository repository, S3Service s3Service) {
        this.repository = repository;
        this.s3Service = s3Service;
    }

    public User getUser(Long id) {
        User user = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));
        if (user.getAvatarId() == null || user.getAvatarId().isEmpty()) {
            // если avatarId пустой — используем дефолтный
            user.setAvatarId(defaultAvatarUrl);
        }
        return user;
    }

    public User updateAvatar(Long id, MultipartFile file) throws Exception {
        User user = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));
        String url = s3Service.uploadFile(file.getInputStream(), file.getContentType());
        user.setAvatarId(url);
        return repository.save(user);
    }

    public String getAvatarUrl(Long id) {
        User user = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));

        if (user.getAvatarId() == null || user.getAvatarId().isEmpty()) {
            user.setAvatarId(defaultAvatarUrl);
        }

        return user.getAvatarId();
    }

    public byte[] downloadAvatar(String avatarUrl) throws Exception {
        return s3Service.downloadFile(avatarUrl);
    }

    public String getAvatarContentType(String avatarUrl) throws Exception {
        return s3Service.getFileContentType(avatarUrl);
    }

}