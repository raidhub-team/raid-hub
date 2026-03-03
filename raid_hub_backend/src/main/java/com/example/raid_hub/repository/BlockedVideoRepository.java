package com.example.raid_hub.repository;

import com.example.raid_hub.entity.BlockedVideo;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BlockedVideoRepository extends JpaRepository<BlockedVideo, Long> {
  Optional<BlockedVideo> findByVideoId(String videoId);
}
