package com.example.raid_hub.service;

import com.example.raid_hub.entity.BlockedVideo;
import com.example.raid_hub.repository.BlockedVideoRepository;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class BlockedVideoService {

  private final BlockedVideoRepository blockedVideoRepository;

  @Transactional
  public BlockedVideo blockVideo(String videoId, String reason) {
    return blockedVideoRepository
        .findByVideoId(videoId)
        .orElseGet(
            () -> {
              BlockedVideo blockedVideo =
                  BlockedVideo.builder().videoId(videoId).reason(reason).build();
              return blockedVideoRepository.save(blockedVideo);
            });
  }

  @Transactional
  public void unblockVideo(String videoId) {
    blockedVideoRepository.findByVideoId(videoId).ifPresent(blockedVideoRepository::delete);
  }

  @Transactional(readOnly = true)
  public List<String> getBlockedVideoIds() {
    return blockedVideoRepository.findAll().stream().map(BlockedVideo::getVideoId).toList();
  }
}
