package com.example.raid_hub.controller;

import com.example.raid_hub.entity.BlockedVideo;
import com.example.raid_hub.service.BlockedVideoService;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/blocked-videos")
@RequiredArgsConstructor
@Slf4j
public class BlockedVideoController {

  private final BlockedVideoService blockedVideoService;

  @PostMapping
  public ResponseEntity<BlockedVideo> blockVideo(@RequestBody Map<String, String> request) {
    String videoId = request.get("videoId");
    log.info("Request to block video: {}", videoId);
    String reason = request.get("reason");
    BlockedVideo blockedVideo = blockedVideoService.blockVideo(videoId, reason);
    return ResponseEntity.ok(blockedVideo);
  }

  @GetMapping
  public ResponseEntity<List<String>> getBlockedVideoIds() {
    List<String> ids = blockedVideoService.getBlockedVideoIds();
    log.info("Fetching {} blocked video IDs", ids.size());
    return ResponseEntity.ok(ids);
  }

  @DeleteMapping("/{videoId}")
  public ResponseEntity<Void> unblockVideo(@PathVariable String videoId) {
    log.info("Request to unblock video: {}", videoId);
    blockedVideoService.unblockVideo(videoId);
    return ResponseEntity.noContent().build();
  }
}
