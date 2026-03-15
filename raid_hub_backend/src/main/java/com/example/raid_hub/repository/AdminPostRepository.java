package com.example.raid_hub.repository;

import com.example.raid_hub.entity.AdminPost;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AdminPostRepository extends JpaRepository<AdminPost, Long> {
  List<AdminPost> findAllByOrderByCreatedAtDesc();
}
