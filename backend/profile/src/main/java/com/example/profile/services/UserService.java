package com.example.profile.services;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.example.profile.dto.UserDto;
import com.example.profile.dto.UserUpdateDto;
import com.example.profile.models.User;
import java.util.List;
import com.example.profile.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UserService {
    private static final Logger log = LoggerFactory.getLogger(UserService.class);
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
            user.setAvatarId(defaultAvatarUrl);
        }
        return user;
    }

    public User updateAvatar(Long id, MultipartFile file) throws Exception {
        log.debug("awdhwaudhawjawihawduhawauowhfuiehfliauwefuiesfhulewahflaiuewflawifhelwifuhelhfliuwehfluihfwegfuiewh");
        log.debug(">>> updateAvatar called for user: " + id);
        log.debug(">>> file name: " + file.getOriginalFilename());
        log.debug(">>> content type: " + file.getContentType());

        User user = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));

        String fileName = s3Service.uploadFile(file.getInputStream(), file.getContentType());
        user.setAvatarId(fileName); // сохраняем имя, не URL

        return repository.save(user);
    }

    public String getAvatarUrl(Long id) throws Exception {
        User user = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Пользователь не найден"));

        if (user.getAvatarId() == null || user.getAvatarId().isEmpty()) {
            return defaultAvatarUrl;
        }

        // Генерируем свежий presigned URL при каждом запросе
        return s3Service.getFileUrl(user.getAvatarId());
    }

    public byte[] downloadAvatar(String avatarFileName) throws Exception {
        return s3Service.downloadFile(avatarFileName);
    }

    public String getAvatarContentType(String avatarFileName) throws Exception {
        return s3Service.getFileContentType(avatarFileName);
    }

    public User updateProfile(Long userId, UserUpdateDto userDto) {
        User user = repository.findById(userId)
            .orElseThrow(() -> new RuntimeException("Пользователь не найден"));

        if (userDto.getNickname() != null && !userDto.getNickname().isEmpty()) {
            user.setNickname(userDto.getNickname());
        }

        if (userDto.getEmail() != null && !userDto.getEmail().isEmpty()) {
            user.setEmail(userDto.getEmail());
        }

        return repository.save(user);
    }

    public List<User> getAllUsers() {
        return repository.findAll();
    }

}
