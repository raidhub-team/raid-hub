package com.example.raid_hub.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "cheat_sheets")
public class CheatSheet {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotBlank
  @Column(nullable = false)
  private String title; // 컨닝페이퍼 제목 (예: 4인 에기르 1관문)

  @NotBlank
  @Column(nullable = false)
  private String raidName; // 레이드명 (카멘, 에키드나 등)

  @NotBlank
  @Column(nullable = false)
  private String gate; // 관문 (1관문, 2관문, 전체 등)

  @Column(nullable = true)
  private String uploaderName; // 작성자 이름

  @NotBlank
  @Column(nullable = false)
  private String imageUrl; // 이미지 접근 경로 (예: /uploads/cheatsheets/filename.png)

  @Column(nullable = false, updatable = false)
  private java.time.LocalDateTime createdAt;

  @PrePersist
  protected void onCreate() {
    createdAt = java.time.LocalDateTime.now();
  }
}
