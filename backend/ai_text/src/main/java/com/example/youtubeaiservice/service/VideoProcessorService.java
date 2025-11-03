package com.example.youtubeaiservice.service;

import com.example.youtubeaiservice.client.GptClient;
import com.example.youtubeaiservice.client.WhisperClient;
import org.springframework.stereotype.Service;
import com.example.youtubeaiservice.utils.YouTubeAudioDownloader;


import java.io.File;

@Service
public class VideoProcessorService {

    private final YouTubeAudioDownloader downloader;
    private final WhisperClient whisperClient;
    private final GptClient gptClient;

    public VideoProcessorService(YouTubeAudioDownloader downloader,
                                 WhisperClient whisperClient,
                                 GptClient gptClient) {
        this.downloader = downloader;
        this.whisperClient = whisperClient;
        this.gptClient = gptClient;
    }

    public String processVideo(String videoUrl, String type) {
        File audio = null;
        try {
            audio = downloader.downloadAudio(videoUrl);
            String transcript = whisperClient.transcribe(audio);
            return gptClient.summarize(transcript, type);
        } catch (Exception e) {
            throw new RuntimeException("Ошибка обработки: " + e.getMessage(), e);
        } finally {
            if (audio != null) downloader.deleteFile(audio);
        }
    }
}
